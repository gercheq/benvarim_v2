# -*- coding: utf-8 -*-
class PaymentsController < ApplicationController
  protect_from_forgery :except => [:ipn_handler]
  def new
    if params[:page_id]
      @page = Page.find params[:page_id]
      @organization = @page.organization
      @project = @page.project
    elsif params[:project_id]
      @project = Project.find params[:project_id]
      @organization = @project.organization
    elsif params[:organization_id]
      @organization = Organization.find params[:organization_id]
    else
      flash[:error] = "Bir kurum, proje veya sayfa seçmelisiniz"
      return redirect_to root_path
    end
    @tmp_payment = TmpPayment.new params[:tmp_payment]
    @tmp_payment.page_id = @page.id if @page
    @tmp_payment.project_id = @project.id if @project
    @tmp_payment.organization_id = @organization.id

    if params[:popup]
      render :layout => false
    end

  end

  def create
    puts params
    if params[:page_id]
      @page = Page.find params[:page_id]
      @organization = @page.organization
      @project = @page.project
    elsif params[:project_id]
      @project = Project.find params[:project_id]
      @organization = @project.organization
    elsif params[:organization_id]
      @organization = Organization.find params[:organization_id]
    else
      flash[:error] = "Bir kurum, proje veya sayfa seçmelisiniz"
      return redirect_to root_path
    end

    @tmp_payment = TmpPayment.new params[:tmp_payment]
    @tmp_payment.page_id = @page.id if @page
    @tmp_payment.project_id = @project.id if @project
    @tmp_payment.organization_id = @organization.id

    if @tmp_payment.save
      #goto paypal!
      redirect_to paypal_url(@tmp_payment)
    else
      puts @tmp_payment.errors
      render :new
    end
  end

  def ipn_handler
    #bunu kullanarak kurum verifikasyonu yapabiriliz.
    #sonucta paypali ayarladiklarindan emin olmaliyiz.
    begin
      require 'net/http'
      require 'uri'
      require 'cgi'

      #you need to post back to paypal the name/value string
      #in the same order received w/added cmd=_notify-validate
      from_pp = request.raw_post
      #PAYPAL.info "IPN response #{from_pp}"

      data = from_pp + "&cmd=_notify-validate"
      url = URI.parse(ENV['PAYPAL_IPN_URL'])
      http = Net::HTTP.new url.host, url.port

      response, data = http.post url.path, data, {'Content-Type' => 'application/x-www-for-urlencoded' }

      #PAYPAL.info "IPN paypal handshake return #{response} -- #{data}"
      custom = params[:custom]
      if custom.nil?
        #PAYPAL.info "could not read custom parameter"
        #probably someone else sent money to there.
      else
        if create_payment(custom)
          #PAYPAL.info successfully created payment via IPN
        else
          #PAYPAL.info could not find tmp payment
        end
        #PAYPAL.info rez
      end
      #PAYPAL.info
     rescue Exception => e
       #PAYPAL.error "Error: paypal transaction #{e.message}"
    end
    render :nothing => true
  end



  def finalize
    require 'net/http'
    require 'uri'
    require 'cgi'

    url = URI.parse(ENV['PAYPAL_IPN_URL'])
    if params[:page_id]
      @page = Page.find(params[:page_id])
      @organization = @page.organization
      @project = @page.project
    elsif params[:project_id]
      @project = Project.find(params[:project_id])
      @organization = @project.organization
    elsif params[:organization_id]
      @organization = Organization.find(params[:organization_id])
    end

    id_token = @organization.paypal_info.paypal_id_token
    post_args = { "cmd" => '_notify-synch', "tx" => params[:tx], "at" =>  id_token}
    resp, data = Net::HTTP.post_form(url, post_args)

    return_map = Hash.new
    if data.split("\n").first == 'SUCCESS'
      data.each_line do |line|
        key_val = line.split('=')
        if key_val.length == 2
          return_map[CGI::unescape(key_val[0])] = CGI::unescape(key_val[1])
        end
      end

      tmp_payment_id = params[:cm]
    end

    @payment = nil
    begin
      res = create_payment tmp_payment_id
      if res
        flash[:notice] = "Bağış yapıldı! Teşekkürler!"
      else
        flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
      end

    rescue ActiveRecord::RecordInvalid => invalid
      flash[:error] = invalid.record.errors
    rescue ActiveRecord::RecordNotFound => notfound
      flash[:error] = "Kayıt bulunamadı"
    rescue
      flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
    end

    return redirect_to @page if @page
    return redirect_to @project if @project
    return redirect_to @organization if @organization
    #wtf ??
    redirect_to root_path
    #send emails

  end

  private

    def paypal_url(tmp_payment)
      if tmp_payment.page
        return_url = finalize_donation_for_page_path(tmp_payment.page, :only_path => false)
      elsif tmp_payment.project
        return_url = finalize_donation_for_project_path(tmp_payment.project, :only_path => false)
      else
        return_url = finalize_donation_for_project_path(tmp_payment.organization, :only_path => false)
      end

      paypal_info = tmp_payment.organization.paypal_info
      paypal_user = paypal_info.paypal_user
      values = {
        :cmd => "_xclick",
        :business => paypal_user,
        :currency_code => ENV['PAYPAL_CURRENCY'],
        :upload => 1,
        :return => return_url,
        :charset => "utf-8",
        :amount => tmp_payment.amount,
        :item_name => tmp_payment.organization.name + " - bağış",
        :item_number => tmp_payment.id,
        :quantity => 1
        # ,
        # :currency_code => "TRY"
        #:invoice => id
      }

      values[:custom] = tmp_payment.id
      ENV['PAYPAL_URL']+ "?" + values.to_query
    end

    def create_payment tmp_payment_id
      Page.transaction do
        @tmp_payment = TmpPayment.find tmp_payment_id
        unless @tmp_payment.payment.nil?
          flash[:notice] = "Bağış yapıldı! Teşekkürler!"
          return true
        end
        attributes = @tmp_payment.attributes
        attributes.delete "id"
        attributes.delete "created_at"
        attributes.delete "updated_at"
        attributes.delete "payment_id"

        page = @tmp_payment.page
        organization = @tmp_payment.organization
        project = @tmp_payment.project

        @payment = Payment.new attributes
        @payment.save!

        @tmp_payment.payment_id = @payment.id
        @tmp_payment.save!

        unless page.nil?
          page.collected += @tmp_payment.amount
          page.save!
        end

        unless organization.nil?
          organization.collected += @tmp_payment.amount
          organization.save!
        end

        unless project.nil?
          project.collected += @tmp_payment.amount
          project.save!
        end
      end
      return true
    end
end
