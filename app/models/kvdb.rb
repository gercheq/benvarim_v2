class Kvdb < ActiveRecord::Base
  def self.get key
    Kvdb.find_by_key(key).where("NOT expires OR expires >= now()")
  end

  def self.insert key, value, timeout = nil
    expires = nil
    if timeout
      rec.expires = Time.now + timeout
    end

    attributes = {
      :key => key,
      :value => value,
      :expires => expires
    }
    rec = Kvdb.find_by_key key
    if rec
      rec.update_attributes! attributes
    else
      rec = Kvdb.new(attributes)
      rec.save!
    end
    return rec
  end
end

# == Schema Information
#
# Table name: kvdbs
#
#  key        :string(128)
#  value      :text
#  expires    :datetime
#  created_at :datetime
#  updated_at :datetime
#

