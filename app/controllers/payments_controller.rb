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
    @tmp_payment.is_express = BvFeature.is_paypal_ec_enabled? && @tmp_payment.organization.paypal_ec_gateway != nil
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
    if @tmp_payment.valid?
      @tmp_payment.assign_yk_postnet_xid
      unless @tmp_payment.ykpostnet_xid.nil?
        send_user_to_ykpostnet @tmp_payment
      else
        send_user_to_paypal @tmp_payment
      end
    else
      puts @tmp_payment.errors
      add_predefined_payments
      render :new
    end
  end

  def send_user_to_ykpostnet tmp_payment
    if tmp_payment.save
      redirect_to redirect_to_ykpostnet_path tmp_payment
    else
      add_predefined_payments
      render :new
    end
  end

  def redirect_to_ykpostnet
    @tmp_payment = TmpPayment.find_by_id params[:id]
    #sanity check
    if @tmp_payment.ykpostnet_xid.nil? 
      return redirect_to @tmp_payment.organization
    end

    @ykpostnet_info = @tmp_payment.organization.get_ykpostnet_info
    @post_url = URI.parse(ENV['YKPOSTNET_URL']);
    @success_url = ykpostnet_success_url(@tmp_payment)
    @fail_url = ykpostnet_fail_url(@tmp_payment)
    
    render :layout => false
  end

  def send_user_to_paypal tmp_payment
    if tmp_payment.is_express
      gateway = tmp_payment.organization.paypal_ec_gateway
      puts paypal_ec_params(tmp_payment)
      response = gateway.setup_purchase(tmp_payment.amount_in_currency * 100,
          paypal_ec_params(tmp_payment))
      puts response.params
      #TODO
      #what if paypal request fails ???
      if !response || !response.token
        puts tmp_payment.errors
        add_predefined_payments
        tmp_payment.errors.add :express_token, "Paypal'a ulaşamadık. Lütfen tekrar deneyiniz."
        return render :new
      end
      tmp_payment.express_token = response.token
    end


    if tmp_payment.save
      if tmp_payment.is_express
        gateway = tmp_payment.organization.paypal_ec_gateway
        redirect_to gateway.redirect_url_for(tmp_payment.express_token)
      else
        #goto paypal!
        redirect_to paypal_url(tmp_payment)
      end
    else
      puts tmp_payment.errors
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
    begin
      @new_payment = TmpPayment.new(tmp_payment.attributes.merge({:express_token => nil, :id => nil, :created_at => nil, :updated_at => nil}))
      if @new_payment.save
        #goto paypal!
        send_user_to_paypal @new_payment
      else
        raise Exception.new("Kayıt eklenemedi")
      end
    rescue
      flash[:error] = "Beklenmedik bir hata oluştu, lütfen tekrar deneyiniz"
      return redirect_to tmp_payment.page if tmp_payment.page
      return redirect_to tmp_payment.project if tmp_payment.project
      return redirect_to tmp_payment.organization if tmp_payment.organization
      return redirect_to root_path #wtf
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
      BvLogger::log("ipn_handler", "response : #{response} , data: #{data} ")
      #PAYPAL.info "IPN paypal handshake return #{response} -- #{data}"
      custom = params[:custom]
      if custom.nil?
        #PAYPAL.info "could not read custom parameter"
        #probably someone else sent money to there.
      else
        tmp_payment = TmpPayment.find_by_id custom
        payment = BvPayment.finalize tmp_payment
        if payment
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
    # Check some parameters to make sure its coming from ykpostnet
    if params[:xid] && params[:xid]!="" && params[:returncode] && params[:returncode]=="1"
      tmp_payment = TmpPayment.find_by_ykpostnet_xid params[:xid]
    elsif params[:token]
      #paypal express
      #TODO
      #assuming token is uniq, make sure!
      tmp_payment = TmpPayment.find_by_express_token params[:token]
    else
      require 'net/https'
      require 'net/http'
      require 'uri'
      require 'cgi'

      url = URI.parse(ENV['PAYPAL_URL'])
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
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url.request_uri)
      request.set_form_data post_args
      response = http.request(request)
      if response && response.code.to_i == 200
        data = response.body
        BvLogger::log("paypal_finalize", data)

        return_map = Hash.new
        if data.split("\n").first == 'SUCCESS'
          data.each_line do |line|
            key_val = line.split('=')
            if key_val.length == 2
              return_map[CGI::unescape(key_val[0])] = CGI::unescape(key_val[1])
            end
          end

          tmp_payment_id = params[:cm]
          tmp_payment = TmpPayment.find_by_id tmp_payment_id
        end
        BvLogger::log("paypal_finalize", return_map.to_json)
      else
        if response.nil?
          BvLogger::log("paypal_finalize", "null response :/")
        else
          BvLogger::log("paypal_finalize", "response code invalid #{response.code}")
        end

      end
    end

    if tmp_payment.nil?
      #wtf
      flash[:error] = "Beklenmedik bir hata oluştu"
      return redirect_to root_path
    end

    begin
      @payment = BvPayment.finalize tmp_payment
      if @payment
        flash[:success] = "Bağış yapıldı! Teşekkürler!"
        BvLogger::log("paypal_finalize", "success")
      else
        flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
        BvLogger::log("paypal_finalize", "error")
      end

    rescue BvExceptions::PaymentError => err
      flash[:error] = err.message
      BvLogger::log("paypal_finalize", "#{err.message}")
    rescue Exception => ee
      flash[:error] = "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz"
      BvLogger::log("paypal_finalize", "unidentified error #{ee.backtrace}")
    end

    unless tmp_payment.nil?
      return redirect_to tmp_payment.page if tmp_payment.page
      return redirect_to tmp_payment.project if tmp_payment.project
      return redirect_to tmp_payment.organization if tmp_payment.organization
    end
    #wtf ??
    redirect_to root_path
    #send emails

  end

  private

    def paypal_return_url(tmp_payment)
      if tmp_payment.page
        return_url = finalize_donation_for_page_path(tmp_payment.page, :only_path => false)
      elsif tmp_payment.project
        return_url = finalize_donation_for_project_path(tmp_payment.project, :only_path => false)
      else
        return_url = finalize_donation_for_organization_path(tmp_payment.organization, :only_path => false)
      end
      return_url
    end
    def paypal_cancel_url(tmp_payment)
      if tmp_payment.page
        cancel_url = page_path(tmp_payment.page, :only_path => false)
      elsif tmp_payment.project
        cancel_url = project_path(tmp_payment.project, :only_path => false)
      else
        cancel_url = organization_path(tmp_payment.organization, :only_path => false)
      end
      cancel_url
    end

    def ykpostnet_success_url(tmp_payment)
      if tmp_payment.page
        success_url = finalize_donation_for_page_path(tmp_payment.page, :only_path => false)
      elsif tmp_payment.project
        success_url = finalize_donation_for_project_path(tmp_payment.project, :only_path => false)
      else
        success_url = finalize_donation_for_organization_path(tmp_payment.organization, :only_path => false)
      end
      success_url
    end

    def ykpostnet_fail_url(tmp_payment)
      if tmp_payment.page
        fail_url = page_path(tmp_payment.page, :only_path => false)
      elsif tmp_payment.project
        fail_url = project_path(tmp_payment.project, :only_path => false)
      else
        fail_url = organization_path(tmp_payment.organization, :only_path => false)
      end
      fail_url
    end

    def paypal_ec_params(tmp_payment)
      {
        :currency => tmp_payment.currency,
        :ip                => request.remote_ip,
        :return_url        => paypal_return_url(tmp_payment),
        :cancel_return_url => paypal_cancel_url(tmp_payment),
        :header_image => tmp_payment.organization.logo.url(:thumb),
        :landing_page => 'Billing',
        :email => tmp_payment.email,
        :locale => 'tr_TR',
        :brand_name => tmp_payment.organization.name,
        :description => "#{tmp_payment.organization.name} - bağış",
        :no_shipping => 1,
        :allow_guest_checkout => true,
        :custom => "#{tmp_payment.id}",
        :items => paypal_ec_items(tmp_payment)
      }
    end

    def paypal_ec_items tmp_payment
      base = {}
      if tmp_payment.page
        base = {
          :name => tmp_payment.page.title,
          :url => page_path(tmp_payment.page, :only_path => false)
        }
      elsif tmp_payment.project
        base = {
          :name => tmp_payment.project.name,
          :url => project_path(tmp_payment.project, :only_path => false)
        }
      else
        base = {
          :name => tmp_payment.organization.name,
          :url => organization_path(tmp_payment.organization, :only_path => false)
        }
      end
      return [base.merge({
        :amount => tmp_payment.amount_in_currency * 100,
        :category => 'Physical',
        :number => tmp_payment.id,
        :quantity => 1,
        :description => "#{base[:name]} - bağış",
      })]

    end
    def paypal_url(tmp_payment)
      return_url = paypal_return_url tmp_payment

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
        :quantity => 1,
        :no_shipping => 1
        # ,
        # :currency_code => "TRY"
        #:invoice => id
      }

      values[:custom] = tmp_payment.id
      ENV['PAYPAL_URL']+ "?" + values.to_query
    end
end
