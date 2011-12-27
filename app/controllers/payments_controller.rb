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
    @tmp_payment.currency = @organization.paypal_info.currency
    add_predefined_payments

    if params[:popup]
      render :layout => false
    end

  end

  def add_predefined_payments
    @predefined_payments = []
    if @project
      @predefined_payments = @project.predefined_payments.where("NOT deleted AND NOT disabled").order("amount DESC")
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
      flash[:error] = "Bir kurum, proje veya sayfa seçmelisiniz."
      return redirect_to root_path
    end

    @tmp_payment = TmpPayment.new params[:tmp_payment]
    @tmp_payment.page_id = @page.id if @page
    @tmp_payment.project_id = @project.id if @project
    @tmp_payment.organization_id = @organization.id
    @tmp_payment.currency = @organization.paypal_info.currency
    #make sure if there is a predefined payment id, it is valid!
    if @tmp_payment.predefined_payment_id && @tmp_payment.predefined_payment_id > 0
      pp = PredefinedPayment.find @tmp_payment.predefined_payment_id
      if pp.project_id != @tmp_payment.project_id
        flash[:error] = "Seçilen ödeme bu projeye ait değil"
        return redirect_to @page if @page
        return redirect_to @project if @project
        return redirect_to @organization if @organization
      end
      @tmp_payment.amount_in_currency = pp.amount
    end


    if @tmp_payment.save
      #goto paypal!
      redirect_to paypal_url(@tmp_payment)
    else
      puts @tmp_payment.errors
      add_predefined_payments
      render :new
    end
  end

  def tmp_payment_retry
    tmp_payment = TmpPayment.find(params[:id])
    if tmp_payment.payment != nil || !tmp_payment.can_be_completed? || tmp_payment.retry_key != params[:retrykey]
      if tmp_payment.payment
        flash[:success] = "Bağış yapıldı! Teşekkürler!"
      end
      return redirect_to tmp_payment.page if tmp_payment.page
      return redirect_to tmp_payment.project if tmp_payment.project
      return redirect_to tmp_payment.organization if tmp_payment.organization
      return redirect_to root_path #wtf
    end
    #duplicate tmp payment not to have problems if user completes twice, screws data, we know :/
    @new_payment = TmpPayment.new(tmp_payment.attributes.merge({:created_at => nil, :updated_at => nil}))
    if @new_payment.save
      #goto paypal!
      redirect_to paypal_url(@new_payment)
    else
      flash[:error] = "Beklenmedik bir hata oluştu, lütfen tekrar deneyiniz"
      redirect_to :root
    end
  end

  def ipn_handler
    #bunu kullanarak kurum verifikasyonu yapabiriliz.
    #sonucta paypali ayarladiklarindan emin olmaliyiz.
    BvLogger::log("ipn_handler", "start")
    BvLogger::log("ipn_handler", params.to_json)
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
          BvLogger::log("ipn_handler", "success in create_payment")
          #PAYPAL.info successfully created payment via IPN
        else
          BvLogger::log("ipn_handler", "problem in create_payment")
        end
        #PAYPAL.info rez
      end
      #PAYPAL.info
     rescue Exception => e
       #PAYPAL.error "Error: paypal transaction #{e.message}"
       BvLogger::log("ipn_handler", "exception in create_payment : #{e.message}")
       BvLogger::log("ipn_handler", e.to_json)
    end
    render :nothing => true
  end



  def finalize
    BvLogger::log("paypal_finalize", "start")
    BvLogger::log("paypal_finalize", params.to_json)
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
    BvLogger::log("paypal_finalize", post_args.to_json)

    resp, data = Net::HTTP.post_form(url, post_args)
    BvLogger::log("paypal_finalize", resp)

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
    BvLogger::log("paypal_finalize", return_map.to_json)

    @payment = nil
    begin
      res = create_payment tmp_payment_id
      if res
        flash[:success] = "Bağış yapıldı! Teşekkürler!"
        BvLogger::log("paypal_finalize", "success")
      else
        flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
        BvLogger::log("paypal_finalize", "error")
      end

    rescue ActiveRecord::RecordInvalid => invalid
      flash[:error] = invalid.record.errors
      BvLogger::log("paypal_finalize", "invalid record error")
      BvLogger::log("paypal_finalize", invalid.to_json)
    rescue ActiveRecord::RecordNotFound => notfound
      flash[:error] = "Kayıt bulunamadı"
      BvLogger::log("paypal_finalize", "record not found error")
      BvLogger::log("paypal_finalize", notfound.to_json)
    rescue
      flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
      BvLogger::log("paypal_finalize", "unidentified error")
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
        return_url = finalize_donation_for_organization_path(tmp_payment.organization, :only_path => false)
      end

      puts return_url

      paypal_info = tmp_payment.organization.paypal_info
      paypal_user = paypal_info.paypal_user
      values = {
        :cmd => "_xclick",
        :business => paypal_user,
        :currency_code => tmp_payment.currency,
        :upload => 1,
        :return => return_url,
        :charset => "utf-8",
        :amount => tmp_payment.amount_in_currency,
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
          flash[:success] = "Bağış yapıldı! Teşekkürler!"
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
        predefined_payment = @tmp_payment.predefined_payment

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

        unless predefined_payment.nil?
          predefined_payment.collected += @tmp_payment.amount
          predefined_payment.count += 1
          predefined_payment.save!
        end
      end
      return true
    end
end
