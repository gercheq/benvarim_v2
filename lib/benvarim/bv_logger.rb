class BvLogger
  def self.log(namespace, content)
    log = Bvlog::create({
      "namespace" => namespace,
      "content" => content
      #todo, grab controller and action from current controller
    })
    log.save
    return log
  end

  def self.paymentLog(content)
    return self.log("payment", content)
  end
end