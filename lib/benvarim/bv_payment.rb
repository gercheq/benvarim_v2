# -*- coding: utf-8 -*-
class BvPayment
  def self.finalize tmp_payment
    unless tmp_payment.express_token.nil?
      #paypal ec
      self.finalize_paypal_ec tmp_payment
    else
      #paypal standard
      return self.create_payment tmp_payment
    end
  end

  def self.create_payment tmp_payment
    payment = nil
    begin
      Page.transaction do
        unless tmp_payment.payment.nil?
          return tmp_payment.payment
        end
        attributes = tmp_payment.attributes
        attributes.delete "id"
        attributes.delete "created_at"
        attributes.delete "updated_at"
        attributes.delete "payment_id"
        attributes.delete "is_express"

        page = tmp_payment.page
        organization = tmp_payment.organization
        project = tmp_payment.project
        predefined_payment = tmp_payment.predefined_payment

        payment = Payment.new attributes
        payment.save!

        tmp_payment.payment_id = payment.id
        tmp_payment.save!

        unless page.nil?
          page.collected += tmp_payment.amount
          page.save!
        end

        unless organization.nil?
          organization.collected += tmp_payment.amount
          organization.save!
        end

        unless project.nil?
          project.collected += tmp_payment.amount
          project.save!
        end

        unless predefined_payment.nil?
          predefined_payment.collected += tmp_payment.amount
          predefined_payment.count += 1
          predefined_payment.save!
        end
      end
      return payment
    rescue ActiveRecord::RecordInvalid => invalid
      BvLogger::log("paypal_finalize", "invalid record error")
      BvLogger::log("paypal_finalize", invalid.to_json)
      raise BvExceptions::PaymentError.new(true, "Ödeme tamamlanamadı")
    rescue ActiveRecord::RecordNotFound => notfound
      BvLogger::log("paypal_finalize", "record not found error")
      BvLogger::log("paypal_finalize", notfound.to_json)
      raise BvExceptions::PaymentError.new(true, "Kayıt bulunamadı")
    rescue Exception => ee
      BvLogger::log("paypal_finalize", "unidentified error #{ee.backtrace}")
      raise BvExceptions::PaymentError.new(true, "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz")
    rescue
      raise BvExceptions::PaymentError.new(true, "Beklenmedik bir hata oluştu. Lütfen tekrar deneyiniz")
    end
  end


  def self.finalize_paypal_ec tmp_payment
    #get details
    gateway = tmp_payment.organization.paypal_ec_gateway
    details = gateway.details_for tmp_payment.express_token
    status = details.params['checkout_status']
    case status
      when "PaymentActionCompleted"
        #already confirmed with paypal
        #try to create payment if we have not already
        return self.create_payment tmp_payment
      when "PaymentActionNotInitiated"
        #need to confirm with paypal , we dunno wtf has happened :/
        payer_info = details.params['PayerInfo']
        if payer_info.nil? || payer_info['PayerID'].nil?
          raise BvExceptions::PaymentError.new(false, "Ödeme tamamlanmamış")
        end
        payer_id = payer_info['PayerID']
        response = gateway.purchase(tmp_payment.amount_in_currency * 100,
          {:token => tmp_payment.express_token , :payer_id => payer_id, :currency => tmp_payment.organization.paypal_info.currency})
        if response.nil?
          #wtf paypal
          raise BvExceptions::PaymentError.new(true, "Beklenmedik bir hata oluştu")
        end
        payment_info = response.params['PaymentInfo']
        if payment_info.nil?
          #wtf
          raise BvExceptions::PaymentError.new(false, "Ödeme tamamlanmamış")
        end
        #ok we, got the payment ;)
        return self.create_payment tmp_payment
      when "PaymentActionFailed"
        #failed
        raise BvExceptions::PaymentError.new(false, "Ödeme tamamlanmamış")
      when "PaymentActionInProgress"
        raise BvExceptions::PaymentError.new(false, "Ödeme tamamlanmamış")
      else
        #wtf?
        raise BvExceptions::PaymentError.new(false, "Beklenmedik bir hata oluştu")
      end
    BvLogger::log("paypal_finalize", "ec tmp payment id #{tmp_payment.id}")
  end
end