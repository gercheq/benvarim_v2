# -*- coding: utf-8 -*-
class OrganizationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default :from => "iletisim@benvarim.com"
  def dailymail(name, email, organization, pages, payments)
  	@organization = organization
  	@pages = pages
  	@payments = payments
  	@name = name
  	@email =email
  	mail(:to => email,
         :bcc => "team@benvarim.com",
         :subject => "Benvarim.com günlük özet - #{organization.name}",
         "X-SMTPAPI" => '{"category": "organization"}')
  end

  def send_daily_mail
    now = Time.now.in_time_zone("Istanbul")
    self.send_daily_mail_for_days((now - 1.day),now)
  end
  def send_daily_mail_for_days(start_date, end_date)
    pagesQuery = Organization.includes(:pages).where("pages.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    paymentQuery = Organization.includes(:payments).where("payments.created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
    organizations = (pagesQuery + paymentQuery).uniq
    organizations.each do |organization|
      pages = organization.pages.where("created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
      payments = organization.payments.where("created_at between ? and ?", start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d'))
      if pages.length || payments.length
        OrganizationMailer.dailymail(organization.user.name, organization.user.email, organization, pages, payments).deliver
        if organization.user.email != organization.contact_email
          OrganizationMailer.dailymail(organization.contact_name, organization.contact_email, organization, pages, payments).deliver
        end
      end
    end
  end
end
