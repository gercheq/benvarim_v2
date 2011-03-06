# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20110303082136
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
#

class Organization < ActiveRecord::Base
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:safe_filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :address, :description_html, :logo

  has_many :projects
  has_many :pages
  has_many :payments
  belongs_to :user

  before_validation :sanitize_description_html

  after_create :after_create_hook

  validates :user_id, :presence => true
  validates :name, :length => { :minimum => 5, :maximum => 100 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}

  def safe_filename
    transliterate(logo_file_name)
  end

  def after_create_hook
    #create default project
    p = self.projects.build({
      :name => "Genel Bağış",
      :description => self.description
    })
    p.save
  end


  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end
end
