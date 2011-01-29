# == Schema Information
# Schema version: 20110128071055
#
# Table name: organizations
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  name        :string(255)
#  address     :string(255)
#  description :text
#  approved    :boolean
#  active      :boolean
#

class Organization < ActiveRecord::Base
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "300x300>",
                                   :thumb => "100x100>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :description, :logo

  has_many :projects
  belongs_to :user
end
