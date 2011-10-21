# -*- coding: utf-8 -*-
class OrganizationMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def dailymail(organization,pages)
  	@organization = organization
  	@pages = pages

    mail(:to => organization.user.email,
        # :bcc => "team@benvarim.com",
        :subject => "Benvarim - %s isimli kurumunuza bugün yapılan bağışlar" % [organization.name],
        "X-SMTPAPI" => '{"category": "dailypage"}')

  end

  def send_daily_page_emails
    now = Time.now.in_time_zone("Istanbul")
    self.send_page_email_for_days((now - 1.day),now)
  end
  def send_page_email_for_days(start_date, end_date)
    query = Organization.joins(:pages).where("pages.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    query.each do |organization|
      pages = organization.pages.where("created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
      if pages.length
        self.daily_page_mail(organization, pages).deliver
      end
    end
  end


end
