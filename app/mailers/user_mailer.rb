# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "postaci@benvarim.com"
  def signup user
    @user = user
    mail(:to => user.email,
         :subject => "Benvarim.com'a Hoşgeldiniz!",
         "X-SMTPAPI" => '{"category": "welcome"}')
  end
end
