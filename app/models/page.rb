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
  has_many :tmp_payments
  has_many :payments

  before_validation :sanitize_description_html

  validates :organization_id, :presence => true
  validates :project_id, :presence => true
  validates :user_id, :presence => true
  validates :title, :length => { :minimum => 5, :maximum => 140 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}

  validates_numericality_of :goal, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100000
  validates_numericality_of :collected, :greater_than_or_equal_to => 0

  def collect_ratio
    return 0 if (self.collected == 0 || self.goal == 0)
    return 100 if (self.collected >= self.goal)
    return (self.collected / self.goal)
  end

  def collect_ratio_str
    "%.2f" % self.collect_ratio
  end

  def collected_str
    "%.2f" % self.collected
  end

  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end

end
