# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20110303082136
#
# Table name: tmp_payments
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  note            :text
#  email           :string(255)
#  page_id         :integer
#  project_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  amount          :float
#  payment_id      :integer
#  organization_id :integer
#

class TmpPayment < ActiveRecord::Base

  belongs_to :page
  belongs_to :project
  belongs_to :payment
  belongs_to :organization

  validate :validate_email
  validates_numericality_of :amount, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 500
  validates_presence_of :organization_id
  validates :name, :presence => true, :length => {:minimum => 3}


  def validate_email
    self.errors.add "email", "geçersiz" unless self.email =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end

  def validate_amount
    self.errors.add "amount", "geçersiz" if self.amount =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
  end
end
