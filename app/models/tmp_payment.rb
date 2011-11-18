# -*- coding: utf-8 -*-
class TmpPayment < ActiveRecord::Base

  belongs_to :page
  belongs_to :project
  belongs_to :payment
  belongs_to :organization

  validate :validate_email
  validate :active_validation
  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5000
  validates_presence_of :organization_id

  before_validation :calculate_amount

  validates :name, :presence => true, :length => {:minimum => 3}


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
      self.errors.add "currency_exchange", "sisteminde meydana gelen bir hatadan dolayı ödemeniz şuan yapılamamktadır"
      return
    end
    self.amount = self.amount_in_currency * conversion_rate
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
#

