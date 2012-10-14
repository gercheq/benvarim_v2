# -*- coding: utf-8 -*-
class Organization < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  @paypal_ec_gateway = nil
  @ykpostnet_info = nil

  acts_as_taggable

  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => "/:class/:attachment/:id/:style/resim.:extension",
                      :storage => :s3,
                      :s3_protocol => 'https',
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }


  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :description_html, :logo, :website, :email, :phone, :contact_name, :contact_title, :contact_phone, :contact_email, :facebook_url, :twitter_handle

  index_map :fields => [:user_id, :name, :description, :website, :to_param, :visible_tags, :hidden_tags],
            :text => :name,
            :logo => :visible_logo_url,
            :variables => { BvSearch::VAR_CAN_BE_DONATED => :can_be_donated?, BvSearch::VAR_COLLECTED => :collected}

  has_many :projects, :dependent => :delete_all
  has_many :pages, :dependent => :delete_all
  has_many :payments
  belongs_to :user
  has_one :paypal_info
  has_many :tmp_payments
  has_many :supports

  before_validation :sanitize_description_html

  validate :validate_emails

  after_create :after_create_hook
  after_save :after_save_hook
  before_save :before_save_hook

  validates :user_id, :presence => true
  validates :name, :length => { :minimum => 2, :maximum => 100 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 5000}

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true

  def ykpostnet_info
    if @ykpostnet_info.nil?
      # TODO(berkan): If we continue with this on many organizations, move it to db
      # OrganizationID => [MerchantID, TerminalID, PostnetID]
      @ykpostnet_info = {
        22 => [6700000067,67100944,3371]
      }
    end
    return @ykpostnet_info
  end

  def supports_ykpostnet?
    return BvFeature.is_ykpostnet_enabled? && self.ykpostnet_info[self.id]
  end

  def get_ykpostnet_info
    return self.ykpostnet_info[self.id] if self.supports_ykpostnet?
  end

  def safefilename
    transliterate(logo_file_name)
  end

  def validate_emails
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
    self.errors.add "contact_email", "geçersiz" unless self.contact_email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def visible_projects
    Project.filter_out_hidden self.projects
  end

  def hidden_projects
    Project.filter_out_visible self.projects
  end

  def after_create_hook
    #create default project
    p = self.projects.build({
      :name => "#{self.name} - Genel Bağış",
      :description => "#{self.name} için toplanacak genel bağışlar kurumun çeşitli projelerine destek olacaktır."
    })
    p.save
  end

  def collected_str
    number_with_precision(self.collected, :locale => :tr)
  end

  def before_save_hook
    # self.active = true
  end

  def after_save_hook
    puts "obj after save"
    if self.hidden_changed?
      #update hidden of all projects. does not need to be done with a lock, not that critical
      self.projects.each do |p|
        p.update_aggregated_hidden self.hidden
      end
    end
  end

  def can_be_donated?
    return self.cant_be_donated_reason == nil
  end

  def cant_be_donated_reason
    return "Kurum bulunamadı" if self.hidden?
    if self.active?
      return nil
    end
    return "Kurum bilgileri Benvarim.com tarafından henüz onaylanmadığı için bağış yapamazsınız"
  end

  def self.available_organizations
    Organization.filter_out_hidden.where("active=?", true).all
  end

  def self.available_organizations_simple
    self.available_organizations.collect  do |o| { :value => o.name, :id => o.id} end
  end

  def visible_logo_url
     self.logo.file? ? self.logo.url(:thumb) : '/stylesheets/images/logo.gif'
  end

  def hash
    "org#{self.id}".hash
  end

  def eql?(other)
    self.hash == other.hash
  end

  def self.featureds
    Organization.filter_out_hidden.tagged_with("featured")
  end

  def top_pages
    Page.filter_out_hidden self.pages.where("pages.collected > 0").order("pages.collected DESC").limit(3)
  end

  def self.filter_out_hidden relation = nil
    relation ||= Organization
    relation.where("NOT organizations.hidden OR organizations.hidden IS NULL")
  end

  def paypal_ec_gateway
    unless @paypal_ec_gateway.nil?
      return @paypal_ec_gateway
    end

    if Rails.env == "production"
      if self.paypal_info.nil? || !self.paypal_info.use_express
        return nil
      end
      ActiveMerchant::Billing::Base.mode = :production
      data = self.paypal_info.parse_ec_info
      paypal_options = {
        :login => data[0],
        :password => data[1],
        :signature => data[2]
      }
      @paypal_ec_gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
      return @paypal_ec_gateway
    else
      ActiveMerchant::Billing::Base.mode = :test
      paypal_options = {
        :login => "satis_1298099260_biz_api1.benvarim.com",
        :password => "4VDMUG2L45WJ54J3",
        :signature => "AX52qiaHMK2EmWOU0dqpVvS59TZqAI--JjS2Ph4ZgcY9GMAd9AY8Oo9s"
      }
      @paypal_ec_gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
      return @paypal_ec_gateway
    end
  end


  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end
end



# == Schema Information
#
# Table name: organizations
#
#  id                :integer         not null, primary key
#  user_id           :integer
#  name              :string(255)
#  address           :string(255)
#  description       :text
#  approved          :boolean         default(FALSE)
#  active            :boolean         default(FALSE)
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
#  cached_slug       :string(255)
#  facebook_url      :string(255)
#  twitter_handle    :string(255)
#  hidden            :boolean         default(FALSE)
#

