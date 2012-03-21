class AddExpressTokenToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :express_token, :string
    add_column :tmp_payments, :express_token, :string
  end

  def self.down
    remove_column :payments, :express_token
    remove_column :tmp_payments, :express_token
  end
end
