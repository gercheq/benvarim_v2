class AddDescriptionHtmlToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :description_html, :text
  end

  def self.down
    remove_column :pages, :description_html
  end
end
