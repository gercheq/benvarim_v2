# == Schema Information
# Schema version: 20110409205016
#
# Table name: bvlogs
#
#  id         :integer         not null, primary key
#  namespace  :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class Bvlog < ActiveRecord::Base
end
