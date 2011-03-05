# -*- coding: utf-8 -*-
class PaymentsController < ApplicationController
  def new
    begin
      @page = Page.find params[:id]
      @tmp_payment = @page.tmp_payments.build
    rescue
    end
    if params[:popup]
      render :layout => false
    end
  end

  def create
    @page = Page.find_by_id params[:id]
    if @page.nil?
      #how did i come here??
      return redirect_to root_path
    end
    @tmp_payment = @page.tmp_payments.build params[:tmp_payment]
    @tmp_payment.project_id = @page.project_id
    @tmp_payment.organization_id = @page.organization_id
    if @tmp_payment.save
      #goto paypal!
      redirect_to paypal_url(@tmp_payment, ENV['PAYPAL_RETURN_URL'])
    else
      puts @tmp_payment.errors
      render :new
    end
  end

  def paypal_ipn
    begin
      require 'net/http'
      require 'uri'
      require 'cgi'

      #you need to post back to paypal the name/value string
      #in the same order received w/added cmd=_notify-validate
      from_pp = request.raw_post
      #PAYPAL.info "IPN response #{from_pp}"

      data = from_pp + "&cmd=_notify-validate"
      url = URI.parse(ENV['PAYPAL_URL'])
      http = Net::HTTP.new url.host, url.port

      response, data = http.post url.path, data, {'Content-Type' => 'application/x-www-for-urlencoded' }

      #PAYPAL.info "IPN paypal handshake return #{response} -- #{data}"
      custom = params[:custom]
      if custom.nil?
        #PAYPAL.info "could not read custom parameter"
      else
        tmp_payment = TmpPayment.find_by_id params[:custom]
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

    url = URI.parse(ENV['PAYPAL_URL'])
    post_args = { "cmd" => '_notify-synch', "tx" => params[:tx], "at" =>  ENV['PAYPAL_IDENTITY_TOKEN']}
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
      Page.transaction do
        @tmp_payment = TmpPayment.find tmp_payment_id
        unless @tmp_payment.payment.nil?
          flash[:notice] = "Bağış yapıldı! Teşekkürler!"
          return redirect_to @tmp_payment.page
        end
        @page = @tmp_payment.page
        attributes = @tmp_payment.attributes
        attributes.delete "created_at"
        attributes.delete "updated_at"
        attributes.delete "payment_id"
        @page.collected += @tmp_payment.amount

        @payment = Payment.new attributes
        @payment.save!
        @page.save!
        @tmp_payment.payment_id = @payment.id
        @tmp_payment.save!
      end
    rescue ActiveRecord::RecordInvalid => invalid
      flash[:error] = invalid.record.errors
      return redirect_to @tmp_payment.page unless @tmp_payment.nil?
      return redirect_to root_path
    rescue ActiveRecord::RecordNotFound => notfound
      flash[:error] = "Kayıt bulunamadı"
      return redirect_to @tmp_payment.page unless @tmp_payment.nil?
      return redirect_to root_path
    rescue
      flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
      return redirect_to root_path
    end
    flash[:notice] = "Bağış yapıldı! Teşekkürler!"
    redirect_to @payment.page unless @tmp_payment.nil?
    #send emails

  end

  def paypal_url(tmp_payment, return_url)
    values = {
      :cmd => "_xclick",
      :business => ENV['PAYPAL_USER'],
      :upload => 1,
      :return => return_url,
      :charset => "utf-8",
      :amount => tmp_payment.amount,
      :item_name => tmp_payment.organization.name + " - bağış",
      :item_number => tmp_payment.id,
      :quantity => 1
      #:invoice => id
    }

    values[:custom] = tmp_payment.id
    ENV['PAYPAL_URL']+ "?" + values.to_query
  end
end
