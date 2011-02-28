# == Schema Information
# Schema version: 20110105080422
#
# Table name: pages
#
#  id                :integer         not null, primary key
#  title             :string(255)
#  description       :text
#  start_time        :datetime
#  end_time          :datetime
#  goal              :float           default(0.0)
#  collected         :float           default(0.0)
#  user_id           :integer
#  organization_id   :integer
#  project_id        :integer
#  active            :boolean
#  created_at        :datetime
#  updated_at        :datetime
#  description_html  :text
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#

class Page < ActiveRecord::Base
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/:filename',
                      :storage => :s3,
                      :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                      :styles => { :medium => "600x600>",
                                   :thumb => "200x200>" }

  belongs_to :organization
  belongs_to :user
  belongs_to :project

  before_validation :sanitize_description_html

  validates :organization_id, :presence => true
  validates :project_id, :presence => true
  validates :user_id, :presence => true
  validates :title, :length => { :minimum => 5, :maximum => 100 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}

  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end

end
