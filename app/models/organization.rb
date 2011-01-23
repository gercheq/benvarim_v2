# == Schema Information
# Schema version: 20110122102239
#
# Table name: organizations
#
#  id                   :integer         not null, primary key
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  authentication_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  name                 :string(255)
#  address              :string(255)
#  description          :text
#  approved             :boolean
#  active               :boolean
#  logo_file_name       :string(255)
#  logo_content_type    :string(255)
#  logo_file_size       :integer
#  logo_updated_at      :datetime
#

class Organization < ActiveRecord::Base
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "300x300>",
                                   :thumb => "100x100>" }
  # Include default devise modules. Others available are:
  # :trackable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :address, :description, :logo

  has_many :projects
end
