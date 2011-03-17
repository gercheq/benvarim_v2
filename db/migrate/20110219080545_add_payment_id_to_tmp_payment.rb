class AddPaymentIdToTmpPayment < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :payment_id, :integer
  end

  def self.down
    remove_column :tmp_payments, :payment_id
  end
end
