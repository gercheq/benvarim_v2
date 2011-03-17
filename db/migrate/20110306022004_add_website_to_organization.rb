class AddWebsiteToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :website,    :string
  end

  def self.down
    remove_column :organizations, :website
  end
end
