# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldin!",
         "X-SMTPAPI" => '{"category": "welcome"}')
  end

  def daily_mail(page,payments)
	@page = page
	@payments = payments

    # mail(:to => page.user.email,
    mail(:to => "yboyar@gmail.com",
        :subject => "Benvarim - %s isimli sayfaniza bugün yapilan bagislar" % [page.title],
        "X-SMTPAPI" => '{"category": "daily"}')
  end

  def send_daily_payment_emails
    now = Time.now.in_time_zone("Istanbul")
    self.send_payment_email_for_days((now - 1.day),now)
  end
  def send_payment_email_for_days(start_date, end_date)
    query = Page.joins(:payments).where("payments.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    query.each do |page|
      payments = page.payments.where("created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
      if payments.length
        self.daily_mail(page, payments)
      end
    end
  end
end

