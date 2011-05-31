# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default :from => "postaci@benvarim.com"
  def signup user
    recipients user.email
    from       "postaci@benvarim.com"
    subject    "Benvarim.com'a Hoşgeldiniz"
    sent_on    Time.zone.now
    @user = user
  end
end
