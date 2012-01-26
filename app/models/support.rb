class Support < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
end

# == Schema Information
#
# Table name: supports
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  organization_id :integer
#  referer_id      :integer
#  score           :integer
#  created_at      :datetime
#  updated_at      :datetime
#

