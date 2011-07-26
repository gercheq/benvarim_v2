class CreateFbConnects < ActiveRecord::Migration
  def self.up
    create_table :fb_connects do |t|
      t.integer :user_id
      t.string :fb_user_id
      t.string :extra
      t.string :user_info

      t.timestamps
    end
    add_index :fb_connects, :user_id, :unique => true
  end

  def self.down
    drop_table :fb_connects
  end
end
