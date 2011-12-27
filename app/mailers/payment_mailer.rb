# -*- coding: utf-8 -*-
class PaymentMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def thanks payment
    @payment = payment
    @organization = payment.organization
    @project = payment.project
    @page = payment.page
    if(@page)
      @page_owner = @page.user
    end
    mail(:to => payment.email,
        :bcc => "team@benvarim.com",
         :subject => "Bağışınız İçin Teşekkür Ederiz - Benvarim.com",
         "X-SMTPAPI" => '{"category": "payment_thanks"}')
  end

  def incomplete_paypal tmp_payment
    @tmp_payment = tmp_payment
    @organization = @tmp_payment.organization
    @page = @tmp_payment.page
    @project = @tmp_payment.project
    if(@page)
      @page_owner = @page.user
    end
    mail(:to => tmp_payment.email,
         :subject => "Yarım kalan bağışınız. - Benvarim.com",
         "X-SMTPAPI" => '{"category": "payment_incomplete"}')
  end

end
