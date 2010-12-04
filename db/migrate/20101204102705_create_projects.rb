class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.text :description
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
