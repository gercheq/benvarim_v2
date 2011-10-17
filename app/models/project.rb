# == Schema Information
# Schema version: 20110409205016
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
#  collected         :float           default(0.0)
#  active            :boolean         default(TRUE)
#  cached_slug       :string(255)
#

# -*- coding: utf-8 -*-
class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :tmp_payments
  has_many :payments
  has_many :pages
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/resim.:extension',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

   validates :organization_id, :presence => true
   validates :name, :length => { :minimum => 5, :maximum => 100 }
   validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}

   has_friendly_id :name, :use_slug => true, :approximate_ascii => true

   index_map :fields => [:organization_id, :name, :description, :to_param],
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
     self.active? && self.organization.can_be_donated?
   end
end
