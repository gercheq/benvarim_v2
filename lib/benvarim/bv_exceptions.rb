module BvExceptions
  class PaymentError < StandardError
    @retry = false
    def initialize _retry, msg
      super(msg)
      @retry = _retry
    end
  end

end