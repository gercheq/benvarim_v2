class ContactMailer < ActionMailer::Base
  default :from => "iletisim@benvarim.com"
  def contact_benvarim
    recipients "yigit@benvarim.com"
    from       "team@benvarim.com"
    subject    "Please activate your new account"
    sent_on    Time.zone.now
    body       {}
  end
end
