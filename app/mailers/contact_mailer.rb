class ContactMailer < ActionMailer::Base
  default :from => "team@benvarim.com"
  def test
    recipients "yigit@benvarim.com"
    subject    "Please activate your new account"
    sent_on    Time.zone.now
    body       {}
  end
end
