class ContactMailer < ActionMailer::Base
  default :from => "team@benvarim.com"
  def contact_benvarim contact_form
    recipients "iletisim@benvarim.com"
    from       "iletisim@benvarim.com"
    subject    "Benvarim.com yeni iletisim formu"
    sent_on    Time.zone.now
    @contact_form = contact_form
  end
end
