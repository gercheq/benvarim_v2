# == Schema Information
# Schema version: 20101207064624
#
# Table name: projects
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  start_time      :datetime
#  end_time        :datetime
#  description     :text
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Project < ActiveRecord::Base
  belongs_to :organization
end
