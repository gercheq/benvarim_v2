class AddIsYkpostnetToTmpPaymentAndPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :ykpostnet_xid, :string
    add_column :tmp_payments, :ykpostnet_xid, :string

    add_index('tmp_payments', 'ykpostnet_xid', {:unique => true})
  end

  def self.down
    remove_column :payments, :ykpostnet_xid
    remove_column :tmp_payments, :ykpostnet_xid

    remove_index('tmp_payments', 'ykpostnet_xid')
  end
end
