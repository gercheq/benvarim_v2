class AddCurrencyToPaypalInfo < ActiveRecord::Migration
  def self.up
    add_column :paypal_infos, :currency, :string, :default => "TRY"
  end

  def self.down
    remove_column :paypal_infos, :currency
  end
end
