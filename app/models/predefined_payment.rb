# -*- coding: utf-8 -*-
class PredefinedPayment < ActiveRecord::Base
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

