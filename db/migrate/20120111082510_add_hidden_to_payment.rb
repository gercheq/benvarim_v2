class AddHiddenToPayment < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :hide_name, :boolean, :default => false
    add_column :payments, :hide_name, :boolean, :default => false
  end

  def self.down
    remove_column :tmp_payments, :hide_name
    remove_column :payments, :hide_name
  end
end
