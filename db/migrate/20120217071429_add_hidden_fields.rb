class AddHiddenFields < ActiveRecord::Migration
  def self.up
    add_column :projects, :hidden, :boolean, :default => false
    add_column :organizations, :hidden, :boolean, :default => false
    add_column :pages, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :hidden
    remove_column :organizations, :hidden
    remove_column :pages, :hidden
  end
end
