require 'iconv'
class BvLogger
  def self.to_my_utf8 seq
      ::Iconv.conv('UTF-8//IGNORE', 'UTF-8', seq + ' ')[0..-2]
    end
  def self.log(namespace, content)
    log = Bvlog::create({
      "namespace" => self.to_my_utf8(namespace),
      "content" => self.to_my_utf8(content)
      #todo, grab controller and action from current controller
    })
    log.save
    return log
  end

  def self.paymentLog(content)
    return self.log("payment", content)
  end
end