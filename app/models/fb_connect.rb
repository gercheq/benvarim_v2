class FbConnect < ActiveRecord::Base
  serialize :auth
  belongs_to :user

end

# == Schema Information
#
# Table name: fb_connects
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  fb_user_id :string(255)
#  created_at :datetime
#  updated_at :datetime
#  auth       :text
#

