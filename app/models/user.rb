# == Schema Information
# Schema version: 20110303082136
#
# Table name: users
#
#  id                   :integer         not null, primary key
#  name                 :string(255)
#  address              :string(255)
#  birthday             :date
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  authentication_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  photo_file_name      :string(255)
#  photo_content_type   :string(255)
#  photo_file_size      :integer
#  photo_updated_at     :datetime
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :confirmable, :lockable and :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :validatable
  has_attached_file :photo, :default_url =>'/stylesheets/images/userpic_default.jpg',
                     :path => '/:class/:attachment/:id/:style/:filename',
                     :storage => :s3,
                     :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                     :styles => { :medium => "600x600>",
                                  :thumb => "200x200>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :birthday, :email, :password, :password_confirmation, :remember_me, :photo



  has_many :pages
  has_one :organization

  validates :name, :length => { :minimum => 5, :maximum => 100 }

  before_save do
    self.email.downcase! if self.email
  end

  def self.find_for_authentication(conditions)
    conditions[:email].downcase!
    super(conditions)
  end

  def age
    if !birthday
      return "?"
    end
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end
end
