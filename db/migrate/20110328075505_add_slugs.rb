class AddSlugs < ActiveRecord::Migration
  def self.up
    add_column :users, :cached_slug, :string
    add_index  :users, :cached_slug, :unique => true

    add_column :organizations, :cached_slug, :string
    add_index  :organizations, :cached_slug, :unique => true

    add_column :projects, :cached_slug, :string
    add_index  :projects, :cached_slug, :unique => true

    add_column :pages, :cached_slug, :string
    add_index  :pages, :cached_slug, :unique => true
  end

  def self.down
    remove_column :users, :cached_slug
    remove_column :organizations, :cached_slug
    remove_column :projects, :cached_slug
    remove_column :pages, :cached_slug
  end
end
