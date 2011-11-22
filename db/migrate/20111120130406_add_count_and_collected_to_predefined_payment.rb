class AddCountAndCollectedToPredefinedPayment < ActiveRecord::Migration
  def self.up
    add_column :predefined_payments, :count, :integer, :default => 0
    add_column :predefined_payments, :collected, :float, :default => 0
  end

  def self.down
    remove_column :predefined_payments, :count
    remove_column :predefined_payments, :collected
  end
end
