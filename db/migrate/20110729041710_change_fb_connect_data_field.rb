class ChangeFbConnectDataField < ActiveRecord::Migration
  def self.up
    remove_column :fb_connects, :auth
    add_column :fb_connects, :auth, :text
  end

  def self.down
    remove_column :fb_connects, :auth, :text
    add_column :fb_connects, :auth
  end
end
