class AdminMailer < ActionMailer::Base
  default :from => "team@benvarim.com"
  def paypal_ec_updated_notifier user_id, paypal_info_id
    @user = User.find user_id
    @paypal_info = PaypalInfo.find paypal_info_id
    recipients "yboyar@gmail.com"
    from       "iletisim@benvarim.com"
    subject    "Benvarim.com yeni paypal ec bilgileri"
    sent_on    Time.zone.now
  end
end
