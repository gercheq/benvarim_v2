class IncompletePaymentJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :tmp_payment_id
  def initialize (tmp_payment_id)
    self.tmp_payment_id = tmp_payment_id
    puts "adding incomplete payment job for #{self.to_s}"
  end

  def perform
    puts "performing incomplete payment check job"
    begin
      tmpPayment = TmpPayment.find_by_id self.tmp_payment_id
      if(tmpPayment != nil && tmpPayment.payment == nil &&
        tmpPayment.can_be_completed?)
        PaymentMailer.incomplete_paypal(tmpPayment).deliver
      end
    rescue

    end
    puts "end"
  end

  def to_s
    "#{self.tmp_payment_id}"
  end
end