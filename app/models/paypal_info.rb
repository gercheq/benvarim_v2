# == Schema Information
# Schema version: 20110307002554
#
# Table name: paypal_infos
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  paypal_user     :string(255)
#  paypal_id_token :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class PaypalInfo < ActiveRecord::Base
  belongs_to :organization
end
