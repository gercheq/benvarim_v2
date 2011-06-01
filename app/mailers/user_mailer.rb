# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldin!",
         "X-SMTPAPI" => '{"category": "welcome"}')
  end
end
