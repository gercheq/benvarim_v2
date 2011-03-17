class AddDescriptionHtmlToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :description_html, :text
  end

  def self.down
    remove_column :organizations, :description_html
  end
end
