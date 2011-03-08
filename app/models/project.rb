# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20110105090227
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
#

class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :tmp_payments
  has_many :payments
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

   validates :organization_id, :presence => true
   validates :name, :length => { :minimum => 5, :maximum => 100 }
   validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}

   def to_param
     "#{id}-#{name.downcase.gsub('ö','o').gsub('ı','i').gsub('ğ','g').gsub('ş','s').gsub('ü','u').gsub(/[^a-z0-9]+/i, '-')}"[0..30]
   end
end
