class AddCollectedToOrgAndProject < ActiveRecord::Migration
  def self.up
    add_column :organizations, :collected,  :float, :default => 0
    add_column :projects, :collected,  :float, :default => 0
  end

  def self.down
    remove_column :organizations, :collected
    remove_column :projects, :collected
  end
end
