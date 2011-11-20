# -*- coding: utf-8 -*-
class PredefinedPayment < ActiveRecord::Base
  attr_accessible :name, :description, :disabled, :deleted, :amount, :priority
  belongs_to :project
  validates :name, :length => { :minimum => 1, :maximum => 100 }
  validates_numericality_of :amount, :greater_than_or_equal_to => 1
end


# == Schema Information
#
# Table name: predefined_payments
#
#  id          :integer         not null, primary key
#  project_id  :integer
#  name        :string(255)
#  description :string(255)
#  disabled    :boolean
#  deleted     :boolean
#  created_at  :datetime
#  updated_at  :datetime
#  amount      :integer
#  priority    :integer         default(0)
#

