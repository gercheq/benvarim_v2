# == Schema Information
# Schema version: 20110409205016
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
#  cached_slug          :string(255)
#

# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # , :confirmable, :lockable and :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :validatable, :omniauthable
  has_attached_file :photo, :default_url =>'/stylesheets/images/userpic_default.jpg',
                     :path => '/:class/:attachment/:id/:style/:safe_filename',
                     :storage => :s3,
                     :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                     :styles => { :medium => "600x600>",
                                  :thumb => "200x200>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :birthday, :email, :password, :password_confirmation, :remember_me, :photo

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true



  has_many :pages
  has_many :organizations
  has_one :fb_connect

  after_create :after_create_hook

  validates :name, :length => { :minimum => 5, :maximum => 100 }

  before_save do
    self.email.downcase! if self.email
  end

  def safe_filename
    transliterate(logo_file_name)
  end

  def self.find_for_authentication(conditions)
    conditions[:email].downcase!
    super(conditions)
  end

  def self.send_reset_password_instructions(conditions)
    conditions[:email].downcase!
    super(conditions)
  end

  def self.find_or_create_by_fb_connect fb_connect
    if fb_connect.user
      return fb_connect.user
    elsif fb_connect.user_info["email"]
      email = fb_connect.user_info["email"]
      user = User.find_by_email email
      if user
        user.fb_connect = fb_connect
        #if user does not have photo, attach it!
        if !user.photo.file?
          #create new user
          puts "NO PHOTO"
          sp = URI.split fb_connect.user_info["image"]
          #we need to construct large fb image url :/
          image_url = sp[0] + "://" + sp[2] + sp[5] + "?type=large"
          puts "image url " + image_url
          user.photo = open image_url
        end
        user.save!
        return user
      else
        #create new user
        sp = URI.split fb_connect.user_info["image"]
        #we need to construct large fb image url :/
        image_url = sp[0] + "://" + sp[2] + sp[5] + "?type=large"
        user = User.new({
          :email => email,
          :name => fb_connect.user_info["name"],
          :photo => open(image_url)
        })
        user.fb_connect = fb_connect
        user.save!
        return user
      end
    end
    nil
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    fb_user_id = access_token['uid']

    if user = User.find_by_email(data["email"])
      user
    else
      # Create a user with a stub password.
      # check params
      User.create!(params, :password => Devise.friendly_token[0,20])
    end
  end

  def age
    if !birthday
      return "?"
    end
    now = Time.now.utc.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  def after_create_hook
    begin
    	UserMailer.signup(self).deliver
    rescue
    end
  end
end
