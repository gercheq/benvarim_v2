class CreateSupports < ActiveRecord::Migration
  def self.up
    create_table :supports do |t|
      t.integer :user_id
      t.integer :organization_id
      t.integer :referer_id
      t.integer :score

      t.timestamps
    end
    add_index :supports, :user_id
    add_index :supports, [:organization_id, :user_id], :unique => true
  end

  def self.down
    drop_table :supports
  end
end
