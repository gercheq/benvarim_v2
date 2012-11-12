class MailObserver
  def self.delivered_email(message)
    # Do whatever you want with the message in here
    puts "DELIVERED MESSAGE #{message}"
    receiver_email = message.to
    return if receiver_email.nil?
    receiver = User.find_by_email receiver_email
    return if receiver.nil?
    #track and record
    category = "default"
    extra_str = ""
    begin
      extra = message["X-SMTPAPI"]
      extra_str = extra.to_s
      j = JSON.parse(extra.value)
      category = j["category"]
    rescue

    end
    props = {
      :category => category,
      :extra => extra_str
    }
    BvTrack.track_with_user(receiver, "received_email", props)
  end
end

ActionMailer::Base.register_observer(MailObserver)