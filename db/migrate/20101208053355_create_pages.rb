class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.float :goal, :default => 0
      t.float :collected, :default => 0
      t.integer :user_id
      t.integer :organization_id
      t.integer :project_id
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
