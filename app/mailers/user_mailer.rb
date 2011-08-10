# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldin!",
         "X-SMTPAPI" => '{"category": "welcome"}')
  end

  def dailymail(page,payments) 	
	@page = page
	@payments = payments

  	mail(:to => page.user.email,
        :subject => "Benvarim - %s isimli sayfaniza bugün yapilan bagislar" % [page.title],
        "X-SMTPAPI" => '{"category": "daily"}')
  end

  def doit(day_before)
    time_begin = Time.now - 86400 * day_before  
        
    @pages = Page.all
    @pages.each do |page|
    	#payments = page.payments.where("? >= ? - created_at.yday", day_before, Time.now.yday + (Time.now.year - time_begin.year) * 366).all
	payments = page.payments.all
        inrange_payments = Array.new

	payments.each do |payment|
		creationyday = payment.created_at.yday
		if day_before >= Time.now.yday + (Time.now.year - time_begin.year) * 366 - creationyday
			inrange_payments.push(payment)		
		end
	end
        if !inrange_payments.empty?
    		UserMailer.dailymail(page,inrange_payments).deliver
        end
    end
  end

end

