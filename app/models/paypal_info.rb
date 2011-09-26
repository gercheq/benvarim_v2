class PaypalInfo < ActiveRecord::Base
  belongs_to :organization
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
#

