class Contact < ActionMailer::Base
  def signup_notification(user)
    recipients "#{user.name} <yboyar@gmail.com>"
    from       "My Forum "
    subject    "Please activate your new account"
    sent_on    Time.zone.now
    body       { :user => user}
  end
end