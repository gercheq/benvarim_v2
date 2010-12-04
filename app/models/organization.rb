# == Schema Information
# Schema version: 20101204074142
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
#  approved             :                default("f")
#  active               :                default("f")
#

class Organization < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :trackable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :name, :address, :description

  has_many :projects
end
