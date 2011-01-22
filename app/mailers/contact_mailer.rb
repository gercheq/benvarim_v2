class ContactMailer < ActionMailer::Base
  def test
    mail(:to => "yigit@benvarim.com",
         :subject => "Jetkinlik'e hoalal!")
  end
end