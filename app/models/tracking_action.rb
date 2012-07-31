class TrackingAction < ActiveRecord::Base
  belongs_to :organization
  belongs_to :project
  belongs_to :page

  validates_presence_of :action_id
  validates_numericality_of :action_id, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000

end

# == Schema Information
#
# Table name: tracking_actions
#
#  id              :integer         not null, primary key
#  action_id       :integer
#  email           :string(255)
#  organization_id :integer
#  project_id      :integer
#  page_id         :integer
#  count           :integer
#  amount          :float
#  created_at      :datetime
#  updated_at      :datetime
#

