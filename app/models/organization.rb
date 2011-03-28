# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20110328070645
#
# Table name: organizations
#
#  id                :integer         not null, primary key
#  user_id           :integer
#  name              :string(255)
#  address           :string(255)
#  description       :text
#  approved          :boolean
#  active            :boolean
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  description_html  :text
#  website           :string(255)
#  collected         :float           default(0.0)
#  email             :string(255)
#  phone             :string(255)
#  contact_name      :string(255)
#  contact_title     :string(255)
#  contact_phone     :string(255)
#  contact_email     :string(255)
#

class Organization < ActiveRecord::Base
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => "/:class/:attachment/:id/:style/resim.:extension",
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :description_html, :logo, :website, :email, :phone, :contact_name, :contact_title, :contact_phone, :contact_email

  has_many :projects
  has_many :pages
  has_many :payments
  belongs_to :user
  has_one :paypal_info
  has_many :tmp_payments

  before_validation :sanitize_description_html

  validate :validate_emails

  after_create :after_create_hook
  before_save :before_save_hook

  validates :user_id, :presence => true
  validates :name, :length => { :minimum => 2, :maximum => 100 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 5000}

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true

  def safefilename
    transliterate(logo_file_name)
  end

  def validate_emails
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
    self.errors.add "contact_email", "geçersiz" unless self.contact_email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def after_create_hook
    #create default project
    p = self.projects.build({
      :name => "Genel Bağış",
      :description => "#{self.name} için toplanacak genel bağışlar kurumun çeşitli projelerine destek olacaktır."
    })
    p.save

    #create test paypal information
    # self.paypal_info = PaypalInfo.new(
    #   {"paypal_id_token"=>"r97EMyFtFL6r3bu1ETAacEQYMUeLw6NusWWsDoKb8ER1-hXdzSQ9RByY2hq",
    #     "paypal_user"=>"satis_1298099260_biz@benvarim.com",
    #     "organization_id" => self.id})
    # self.paypal_info.save!

  end

  def before_save_hook
    # self.active = true
  end

  # def to_param
  #   "#{id}-#{name.downcase.gsub('ö','o').gsub('ı','i').gsub('ğ','g').gsub('ş','s').gsub('ü','u').gsub(/[^a-z0-9]+/i, '-')}"[0..30]
  # end

  def can_be_donated?
    self.active?
  end

  def self.available_organizations
    Organization.where("active=?", true).all
  end

  def self.available_organizations_simple
    self.available_organizations.collect  do |o| { :value => o.name, :id => o.id} end
  end


  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end
end
