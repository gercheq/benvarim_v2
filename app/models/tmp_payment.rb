# -*- coding: utf-8 -*-
class TmpPayment < ActiveRecord::Base

  belongs_to :page
  belongs_to :project
  belongs_to :payment
  belongs_to :organization
  belongs_to :predefined_payment

  validate :validate_email
  validate :active_validation
  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5000
  validates_presence_of :organization_id

  before_validation :calculate_amount

  after_create :after_create_hook

  validates :name, :presence => true, :length => {:minimum => 3}

  def retry_key
    Digest::SHA1.hexdigest("#{self.id}-#{self.email}")
  end

  def validate_email
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def human_readable_currency
    BvCurrency.human_readable_currency(self.currency)
  end

  def currency_sign
    BvCurrency.currency_sign(self.currency)
  end

  def validate_amount
    self.errors.add "amount", "geçersiz" if self.amount =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def can_be_completed?
    return ((!self.page || self.page.can_be_donated?) && (!self.project || self.project.can_be_donated?) && self.organization.can_be_donated?)
  end

  def active_validation
    self.errors.add "bağış sayfası", "aktif değil" if self.page && !self.page.can_be_donated?
    unless self.page
      self.errors.add "proje", "aktif değil" if self.project && !self.project.can_be_donated?
      unless self.project
        self.errors.add "kurum", "aktif değil" if self.organization && !self.organization.can_be_donated?
      end
    end
  end

  def calculate_amount
    if !self.amount_in_currency
      return
    end
    conversion_rate = BvCurrency.convert(self.currency, "TRY")
    if(!conversion_rate)
      #wtf, we cannot find conversion rate, is not acceptable to continue w/o it
      #TODO
      #report error! email us etc.
      self.errors.add "currency_exchange", "sisteminde meydana gelen bir hatadan dolayı ödemeniz şu an yapılamamaktadır"
      return
    end
    self.amount = self.amount_in_currency * conversion_rate
  end

  def after_create_hook
    begin
      if self.express_token
        Delayed::Job.enqueue(CaptureExpressCheckoutJob.new(self.id), 0, 2.minutes.from_now)
      end
      Delayed::Job.enqueue(IncompletePaymentJob.new(self.id), 0, 30.minutes.from_now)
    rescue
    end
  end

  def assign_yk_postnet_xid
    #TODO, make sure this is unique from db
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;
    self.ykpostnet_xid  =  (0..19).map{ o[rand(o.length)]  }.join;
  end

end






# == Schema Information
#
# Table name: tmp_payments
#
#  id                    :integer         not null, primary key
#  name                  :string(255)
#  note                  :text
#  email                 :string(255)
#  page_id               :integer
#  project_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  amount                :float
#  payment_id            :integer
#  organization_id       :integer
#  currency              :string(255)     default("TRY")
#  amount_in_currency    :float
#  predefined_payment_id :integer         default(0)
#  hide_name             :boolean         default(FALSE)
#  is_express            :boolean         default(FALSE)
#  express_token         :string(255)
#  ykpostnet_xid         :string(255)
#

