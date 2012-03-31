class BvFeature
  TEST_FEATURES = ["bv_support", "paypal_ec"]
  FEATURE_PREDEFINED_PAYMENTS = "pre-paym"
  @@session = nil
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
  def self.set_session s
    @@session = s
    self.init_session
  end
  def self.has_predefined_payments organization
    #hacky for now :)
    if Rails.env == "production"
      t = [16,22, 9, 6] #unicef, tegv, bugday, tef
      return t.include? organization.id
    else
      return organization.id % 2 == 1 #why, dunno :)
    end
    # return organization.id == 30
  end

  def self.is_support_enabled?
    return self.is_feature_enabled? "bv_support"
  end

  def self.is_paypal_ec_enabled?
    return self.is_feature_enabled? "paypal_ec"
  end

  def self.init_session
    @@session[:bv_features] ||= {}
  end

  def self.enable_feature name
    init_session
    if TEST_FEATURES.include? name
      @@session[:bv_features][name] = true
    end
  end

  def self.disable_feature name
    init_session
    if TEST_FEATURES.include? name
      @@session[:bv_features][name] = false
    end
  end

  def self.is_feature_enabled? name
    return @_env == ActiveSupport::StringInquirer.new(RAILS_ENV) || (@@session[:bv_features] && @@session[:bv_features][name] == true)
  end
end