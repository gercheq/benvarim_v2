class FbConnect < ActiveRecord::Base
  serialize :extra
  serialize :user_info
  belongs_to :user

end
