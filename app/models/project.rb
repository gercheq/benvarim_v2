# -*- coding: utf-8 -*-
class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :tmp_payments
  has_many :payments
  has_many :pages, :dependent => :delete_all
  has_many :predefined_payments
  before_validation :sanitize_description_html

  acts_as_taggable

  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/resim.:extension',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

   validates :organization_id, :presence => true
   validates :name, :length => { :minimum => 5, :maximum => 100 }
   validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}
   validate :validate_payment_options
   validate :validate_end_time
   validates_numericality_of :goal, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000, :allow_nil => true

   has_friendly_id :name, :use_slug => true, :approximate_ascii => true

   index_map :fields => [:organization_id, :name, :description, :visible_tags, :to_param],
             :text => :name,
             :logo => :visible_logo_url,
             :variables => { BvSearch::VAR_CAN_BE_DONATED => :can_be_donated?, BvSearch::VAR_COLLECTED => :collected}

   # def to_param
   #   "#{id}-#{name.downcase.gsub('ö','o').gsub('ı','i').gsub('ğ','g').gsub('ş','s').gsub('ü','u').gsub(/[^a-z0-9]+/i, '-')}"[0..30]
   # end

   def visible_logo_url
     self.logo.file? ? self.logo.url(:thumb) : self.organization.visible_logo_url
   end

   def can_be_donated?
     return self.cant_be_donated_reason == nil
   end

   def cant_be_donated_reason
     return "Proje aktif olmadığı için bağış yapamazsınız." unless self.active?
     return "Projenin süresi dolduğu için bağış yapamazsınız." unless (self.end_time.nil? || self.end_time > Time.now)
     return self.organization.cant_be_donated_reason
   end

   def validate_payment_options
     if self.accepts_random_payment == false && (!self.predefined_payments || self.predefined_payments.where("NOT DELETED").length < 1)
       self.errors.add "öntanımlı ödemelerde", "en az bir ödeme seçeneği olmalı ya da gönüllüler bağış miktarını seçebilsin şıkkı işaretlenmeli"
     end
   end

   def sanitize_description_html
     unless self.description_html.nil?
       self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
     end
   end

   def collect_ratio
     return 0 if (self.collected == 0 || self.goal == 0)
     return 100 if (self.collected >= self.goal)
     return (self.collected / self.goal) * 100
   end

   def did_reach_goal?
     return self.collected >= self.goal
   end

   def collect_ratio_str
     "%.0f" % self.collect_ratio
   end

   def collected_str
     number_with_precision(self.collected, :locale => :tr)
   end

   def goal_str
     number_with_precision(self.goal, :locale => :tr)
   end

   def self.featureds
     Project.tagged_with("featured")
   end

   def validate_end_time
     # if self.end_time_changed? && !self.end_time.nil? && Time.now > self.end_time
     #   self.errors.add "end_time", "bugünden önce olamaz."
     # end
   end
end



# == Schema Information
#
# Table name: projects
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  start_time             :datetime
#  end_time               :datetime
#  description            :text
#  organization_id        :integer
#  created_at             :datetime
#  updated_at             :datetime
#  logo_file_name         :string(255)
#  logo_content_type      :string(255)
#  logo_file_size         :integer
#  logo_updated_at        :datetime
#  collected              :float           default(0.0)
#  active                 :boolean         default(TRUE)
#  cached_slug            :string(255)
#  accepts_random_payment :boolean         default(TRUE)
#  description_html       :text
#  goal                   :float
#

