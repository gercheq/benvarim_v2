class MailJob
  include HerokuDelayedJobAutoscale::Autoscale
  attr_accessor :class_name, :method_name, :args
  def initialize (class_name, method_name, args)
    self.class_name = class_name
    self.method_name = method_name
    self.args = args
    puts "adding email job with for #{self.to_s}"
  end

  def perform
    puts "performing mail send"
    begin
      mailer = self.class_name.constantize
      mailer.send(self.method_name, *self.args).deliver
      puts "sent email for #{self.to_s}"
    rescue
      puts "error while executing email job for #{self.to_s}"
      puts $!
    end
    puts "end"
  end

  def to_s
    "#{self.class_name} #{self.method_name} with args #{self.args}"
  end
end