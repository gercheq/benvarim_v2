class AddDescriptionHtmlToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :description_html, :text
    Project.update_all ["description_html = replace(description, '\n','<br/>')"]
  end

  def self.down
    remove_column :projects, :description_html
  end
end