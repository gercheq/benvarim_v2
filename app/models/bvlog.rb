class Bvlog < ActiveRecord::Base
end

# == Schema Information
#
# Table name: bvlogs
#
#  id         :integer         not null, primary key
#  namespace  :string(255)
#  content    :text
#  controller :string(255)
#  action     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

