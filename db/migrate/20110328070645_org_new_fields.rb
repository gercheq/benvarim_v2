class OrgNewFields < ActiveRecord::Migration
  def self.up
    add_column :organizations, :email, :string
    add_column :organizations, :phone, :string
    add_column :organizations, :contact_name, :string
    add_column :organizations, :contact_title, :string
    add_column :organizations, :contact_phone, :string
    add_column :organizations, :contact_email, :string
  end

  def self.down
    remove_column :organizations, :email
    remove_column :organizations, :phone
    remove_column :organizations, :contact_name
    remove_column :organizations, :contact_title
    remove_column :organizations, :contact_phone
    remove_column :organizations, :contact_email
  end
end
