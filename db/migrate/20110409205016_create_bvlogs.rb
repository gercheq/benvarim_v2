class CreateBvlogs < ActiveRecord::Migration
  def self.up
    create_table :bvlogs do |t|
      t.string :namespace
      t.text :content
      t.string :controller
      t.string :action

      t.timestamps
    end
  end

  def self.down
    drop_table :bvlogs
  end
end
