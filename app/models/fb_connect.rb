class FbConnect < ActiveRecord::Base
  serialize :auth
  belongs_to :user

end
