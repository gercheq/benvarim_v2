class DataToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :name, :string
    add_column :organizations, :address, :string
    add_column :organizations, :description, :text
    add_column :organizations, :approved, :boolean
    add_column :organizations, :active, :boolean
  end

  def self.down
    remove_column :organizations, :name
    remove_column :organizations, :address
    remove_column :organizations, :description
    remove_column :organizations, :approved
    remove_column :organizations, :active
  end
end
