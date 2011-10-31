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
         "X-SMTPAPI" => '{"category": "thanks"}')
  end
end
