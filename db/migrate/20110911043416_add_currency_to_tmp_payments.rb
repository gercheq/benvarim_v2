class AddCurrencyToTmpPayments < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :currency, :string, :default => "TRY"
    add_column :tmp_payments, :amount_in_currency, :float
    TmpPayment.update_all ["currency = ?", "TRY"]
    TmpPayment.update_all ["amount_in_currency = amount"]
  end

  def self.down
    remove_column :tmp_payments, :currency
    remove_column :tmp_payments, :amount_in_currency
  end
end
