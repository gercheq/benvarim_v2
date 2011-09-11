class AddCurrencyToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :currency, :string, :default => "TRY"
    add_column :payments, :amount_in_currency, :float
    Payment.update_all ["currency = ?", "TRY"]
    Payment.update_all ["amount_in_currency = amount"]
  end

  def self.down
    remove_column :payments, :currency
    remove_column :payments, :amount_in_currency
  end
end
