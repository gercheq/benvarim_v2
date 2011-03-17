class AddAmountToPayment < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :amount,    :float
    add_column :payments, :amount,    :float
  end

  def self.down
    remove_column :tmp_payments, :amount
    remove_column :payments, :amount
  end
end
