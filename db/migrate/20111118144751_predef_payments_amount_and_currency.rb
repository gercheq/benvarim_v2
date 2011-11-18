class PredefPaymentsAmountAndCurrency < ActiveRecord::Migration
  def self.up
    add_column :predefined_payments, :amount, :integer
    add_column :predefined_payments, :priority, :integer, :default => 0
  end

  def self.down
    remove_column :predefined_payments, :amount
    remove_column :predefined_payments, :priority
  end
end
