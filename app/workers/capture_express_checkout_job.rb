class CaptureExpressCheckoutJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :tmp_payment_id
  def initialize (tmp_payment_id)
    self.tmp_payment_id = tmp_payment_id
    puts "adding capture paypal ec job for #{self.to_s}"
  end

  def perform
    puts "performing capture paypal ec job"
    begin
      tmpPayment = TmpPayment.find_by_id self.tmp_payment_id
      if(tmpPayment != nil && tmpPayment.payment == nil &&
        tmpPayment.can_be_completed?)
        begin
          BvPayment.finalize tmpPayment
        rescue
          #try till 29 min, 30 will send the email
          if(29 * 60 > tmpPayment.created_at)
            Delayed::Job.enqueue(CaptureExpressCheckoutJob.new(tmpPayment.id), 0, 1.minutes.from_now)
          end
        end
      end
    rescue

    end
    puts "end"
  end

  def to_s
    "#{self.tmp_payment_id}"
  end
end