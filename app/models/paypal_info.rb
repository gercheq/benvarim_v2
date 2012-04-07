class PaypalInfo < ActiveRecord::Base
  belongs_to :organization
  validate :validate_paypal_ec
  @@separator = "|-|"


  def validate_paypal_ec
    puts "validating"
    if self.use_express && self.express_info.nil?
      errors.add :express_info, "Paypal EC bilgilerini girmelisiniz"
    end
  end

  def update_express_info login, password, signature
    login.strip!
    password.strip!
    signature.strip!
    if login.empty? || password.empty? || signature.empty?
      return false
    end
    self.express_info = merge_ec_info login, password, signature
    return true
  end

  def merge_ec_info login, password, signature
    require 'openssl'
    require 'digest/sha1'
    data = [login, password, signature].join(@@separator)
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.encrypt
    c.key = Digest::SHA1.hexdigest(ENV["ec_key"])
    c.update data
    enc = c.final
    return Base64.encode64(enc)
  end

  def parse_ec_info
    require 'openssl'
    require 'digest/sha1'
    if self.express_info.nil?
      return nil
    end
    data = Base64.decode64 self.express_info
    c = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    c.decrypt
    c.key = Digest::SHA1.hexdigest(ENV["ec_key"])
    c.update data
    dec = c.final
    return dec.split(@@separator)
  end
end


# == Schema Information
#
# Table name: paypal_infos
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  paypal_user     :string(255)
#  paypal_id_token :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  currency        :string(255)     default("TRY")
#  use_express     :boolean         default(FALSE)
#  express_info    :text
#

