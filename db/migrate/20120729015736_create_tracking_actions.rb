class CreateTrackingActions < ActiveRecord::Migration
  def self.up
    create_table :tracking_actions do |t|
      t.integer :action_id
      t.string :email
      t.integer :organization_id
      t.integer :project_id
      t.integer :page_id
      t.integer :count
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_actions
  end
end
