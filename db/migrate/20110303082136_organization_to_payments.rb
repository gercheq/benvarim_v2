class OrganizationToPayments < ActiveRecord::Migration
  def self.up
    add_column :tmp_payments, :organization_id,    :integer
    add_column :payments, :organization_id,    :integer
  end

  def self.down
    remove_column :tmp_payments, :organization_id
    remove_column :payments, :organization_id
  end
end
