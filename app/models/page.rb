# -*- coding: utf-8 -*-
class Page < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  has_attached_file :logo, :default_url =>'/stylesheets/images/logo.gif',
                      :path => '/:class/:attachment/:id/:style/resim.:extension',
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
  before_save :update_aggregated_hidden

  validates :organization_id, :presence => true
  validates :project_id, :presence => true
  validates :user_id, :presence => true
  validates :title, :length => { :minimum => 5, :maximum => 240 }
  validates :description, :presence => true, :length => {:minimum => 20, :maximum => 10000}
  validate :organization_and_project_active_validation, :on => :create

  validates_numericality_of :goal, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 1000000
  validates_numericality_of :collected, :greater_than_or_equal_to => 0
  validate :validate_end_time

  has_friendly_id :friendly_id_with_user, :use_slug => true

  after_create :after_create_hook

  index_map :fields => [:user_id, :project_id, :organization_id, :title, :description, :to_param],
             :text => :index_text,
             :human_readable_name => :index_text,
             :logo => :visible_logo_url,
             :variables => { BvSearch::VAR_CAN_BE_DONATED => :can_be_donated?, BvSearch::VAR_COLLECTED => :collected}

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

  def index_text
    self.user.name + " - " + self.title
  end

  def collected_str
    number_with_precision(self.collected, :locale => :tr)
  end

  def goal_str
    number_with_precision(self.goal, :locale => :tr)
  end

  def can_be_donated?
    self.active? && (self.end_time.nil? || self.end_time > Time.now) && self.project.can_be_donated?
  end

  def cant_be_donated_reason
    return "Sayfa aktif olmadığı için bağış yapamazsınız" unless self.active?
    return "Sayfanın süresi dolduğu için bağış yapamazsınız" unless (self.end_time.nil? || self.end_time > Time.now)
    return self.project.cant_be_donated_reason
  end

  def validate_end_time
    # don't validate for now
     # if self.end_time_changed? && !self.end_time.nil? && Time.now > self.end_time
     #   self.errors.add "end_time", "bugünden önce olamaz."
     # end
   end

  # def to_param
  #   "#{id}-#{title.downcase.gsub('ö','o').gsub('ı','i').gsub('ğ','g').gsub('ş','s').gsub('ü','u').gsub(/[^a-z0-9]+/i, '-')}"[0..30]
  # end

  def organization_and_project_active_validation
    self.errors.add "kurum", "aktif değil" if self.organization && !self.organization.active?
    self.errors.add "proje", "aktif değil" if self.project && !self.project.active?
  end

  def friendly_id_with_user
    return "#{id}" if self.user == nil
    self.user.friendly_id
  end

  def visible_logo_url
    self.logo.file? ? self.logo.url(:thumb) : self.project.visible_logo_url
  end

  def after_create_hook
    begin
      Delayed::Job.enqueue MailJob.new("UserMailer", "new_page", self)
    rescue
    end
  end

  def update_aggregated_hidden project_aggregated_hidden = nil
    if project_aggregated_hidden.nil?
      project_aggregated_hidden = self.project.aggregated_hidden
    end
    new_hidden = self.hidden || project_aggregated_hidden
    if self.aggregated_hidden != new_hidden
      self.aggregated_hidden = new_hidden
      self.save!
    end
  end

  private
    def sanitize_description_html
      unless self.description_html.nil?
        self.description = Sanitize.clean(self.description_html).gsub("&#13;", "")
      end
    end

    def transliterate(str)
      if str
        return str.downcase.gsub(/[^a-z0-9]+/i, '-')
      end
      return nil
    end
end



# == Schema Information
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
#  active            :boolean         default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#  description_html  :text
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  cached_slug       :string(255)
#  hidden            :boolean         default(FALSE)
#  aggregated_hidden :boolean         default(FALSE)
#

