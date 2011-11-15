class PredefinedPaymentForPayments < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :predefined_payment_id, :integer, :default => 0
    add_column :payments, :predefined_payment_id, :integer, :default => 0
    add_column :projects, :accepts_random_payment, :boolean, :default => true
  end

  def self.down
    remove_column :tmp_payments, :predefined_payment_id
    remove_column :payments, :predefined_payment_id
    remove_column :projects, :accepts_random_payment
  end
end
