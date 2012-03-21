class AddIsPaypalEcToTmpPayments < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :is_express, :boolean, :default => false
  end

  def self.down
    remove_column :tmp_payments, :is_express
  end
end
