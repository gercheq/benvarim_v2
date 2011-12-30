# -*- coding: utf-8 -*-
class PaymentMailer < ActionMailer::Base
  # add_template_helper("DateHelper")
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


  def send_goal_not_reached_email date
    payments = Payment.joins(:page).where("pages.goal > pages.collected AND payments.created_at BETWEEN ? AND ?", date, date + 1.day)
    payments.each do |payment|
      if payment.page.can_be_donated?
        Delayed::Job.enqueue MailJob.new("PaymentMailer", "page_could_not_reach_goal", payment)
      end
    end
  end

  def page_could_not_reach_goal payment
    @page = payment.page
    @payment = payment
    mail(:to => payment.email,
         :subject => "#{@page.title} isimli sayfanın son durumu - Benvarim.com",
         "X-SMTPAPI" => '{"category": "payment_goal_not_reached"}')
  end



  def send_5_days_goal_not_reached_email
    now = Time.now.in_time_zone("Istanbul")
    PaymentMailer.send_goal_not_reached_email(now - 5.day)
  end

end
