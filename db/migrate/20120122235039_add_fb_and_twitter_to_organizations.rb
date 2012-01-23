class AddFbAndTwitterToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :facebook_url,    :string
    add_column :organizations, :twitter_handle,    :string
  end

  def self.down
    remove_column :organizations, :facebook_url
    remove_column :organizations, :twitter_handle
  end
end
