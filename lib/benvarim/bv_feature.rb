class BvFeature
  FEATURE_PREDEFINED_PAYMENTS = "pre-paym"
  # def self.has_feature feature, obj
  #   key = generate_key feature, obj
  #   kvdb_record = Kvdb.get key
  #   return kvdb_record != nil
  # end
  #
  # def self.add_feature feature, obj, timeout = nil
  #   key = generate_key feature, obj
  #   return Kvdb.insert(key, timeout)
  # end
  #
  # private
  # def generate_key prefix, obj
  #   return "#{prefix}-#{obj.id}"
  # end
  def self.has_predefined_payments organization
    #hacky for now :)
    if Rails.env == "production"
      return organization.id == 16
    else
      return organization.id % 2 == 1 #why, dunno :)
    end
    # return organization.id == 30
  end
end