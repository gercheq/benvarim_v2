class AddLogoToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :logo_file_name,    :string
    add_column :pages, :logo_content_type, :string
    add_column :pages, :logo_file_size,    :integer
    add_column :pages, :logo_updated_at,   :datetime
  end

  def self.down
    remove_column :pages, :logo_file_name
    remove_column :pages, :logo_content_type
    remove_column :pages, :logo_file_size
    remove_column :pages, :logo_updated_at
  end
end
