# == Schema Information
# Schema version: 20110105090227
#
# Table name: projects
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  start_time        :datetime
#  end_time          :datetime
#  description       :text
#  organization_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#

class Project < ActiveRecord::Base
  belongs_to :organization
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "300x300>",
                                   :thumb => "100x100>" }
end
