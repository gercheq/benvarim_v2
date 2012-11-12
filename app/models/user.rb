# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  # Include default devise modules. Others available are:
  # , :confirmable, :lockable and :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :validatable, :omniauthable
  has_attached_file :photo, :default_url =>'/stylesheets/images/userpic_default.jpg',
                     :path => '/:class/:attachment/:id/:style/:safe_filename',
                     :storage => :s3,
                     :s3_protocol => 'https',
                     :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                     :styles => { :medium => "600x600>",
                                  :thumb => "200x200>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :birthday, :email, :password, :password_confirmation, :remember_me, :photo

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true



  has_many :pages
  has_many :organizations
  has_many :supports
  has_one :fb_connect

  after_create :after_create_hook
  after_save :after_save_hook

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
    elsif fb_connect.auth
      user_info = fb_connect.auth['user_info']
      user_hash = fb_connect.auth['extra']['user_hash']
      email = user_info["email"]
      user = User.find_by_email email
      if !user
        #create new user
        user = User.new({
          :email => email,
          :name => user_info["name"],
          :password => Devise.friendly_token[0,20]
        })
      end
      user.fb_connect = fb_connect
      #if there is image and user does not have photo, save it!
      if !user.photo.file? && user_info["image"]
        sp = URI.split user_info["image"]
        #we need to construct large fb image url :/
        if(sp && sp.length > 5)
          image_url = sp[0] + "://" + sp[2] + sp[5] + "?type=large"
          user.photo = open(image_url)
        end
      end

      if !user.birthday && user_hash['birthday']
        user.birthday = Date.strptime(user_hash['birthday'], "%m/%d/%Y")
      end
      user.save!
      return user
    end
    nil
  end

  def total_fundraised
    number_with_precision(self.pages.sum("collected"), :locale => :tr)
  end

  def payments
    Payment.find_all_by_email self.email
  end

  def total_donated
    number_with_precision(self.payments.sum(&:amount), :locale => :tr)
  end

  def total_supporters
    self.supports.sum("score") - self.supports.count
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
      Delayed::Job.enqueue MailJob.new("UserMailer", "signup", self)
    rescue
    end
  end

  def after_save_hook
    Delayed::Job.enqueue TrackUserJob.new(self.id)
  end
end


# == Schema Information
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

