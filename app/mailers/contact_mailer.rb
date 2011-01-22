class ContactMailer < ActionMailer::Base
  default :from => "team@benvarim.com"
  def test
    mail(:to => "yigit@benvarim.com",
         :subject => "Jetkinlik'e hoalal!")
  end
end