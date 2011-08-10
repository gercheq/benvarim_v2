# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldin!",
         "X-SMTPAPI" => '{"category": "welcome"}')
  end

  def dailymail page
  	@payments = Payment.where("? < created_at AND page_id = ?", Time.now.yesterday(), page.id).all
  	@page = page
  	
  	if !@payments.empty?
  		mail(:to => page.user.email,
        	:subject => "Benvarim - %s isimli sayfaniza bugün yapilan bagislar" % [page.title],
        	"X-SMTPAPI" => '{"category": "daily"}')
    end
  end

end
