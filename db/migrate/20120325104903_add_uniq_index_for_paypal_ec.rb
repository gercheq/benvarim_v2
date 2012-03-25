class AddUniqIndexForPaypalEc < ActiveRecord::Migration
  def self.up
    add_index('tmp_payments', 'express_token', {:unique => true})
  end

  def self.down
    remove_index('tmp_payments', 'express_token')
  end
end
