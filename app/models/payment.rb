# -*- coding: utf-8 -*-
class Payment < ActiveRecord::Base
  belongs_to :page
  belongs_to :project
  belongs_to :organization

  validate :validate_email
  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 5000
  validates_presence_of :organization_id

  validates :name, :presence => true, :length => {:minimum => 3}

  def amount_str
    "%.2f" % self.amount
  end

  def amount_in_currency_str
    "%.2f" % self.amount_in_currency
  end

  def human_readable_currency
    BvCurrency.human_readable_currency(self.currency)
  end

  def currency_sign
    BvCurrency.currency_sign(self.currency)
  end


  def validate_email
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def validate_amount
    self.errors.add "amount", "geçersiz" if self.amount =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  note               :text
#  email              :string(255)
#  page_id            :integer
#  project_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  amount             :float
#  organization_id    :integer
#  currency           :string(255)     default("TRY")
#  amount_in_currency :float
#

