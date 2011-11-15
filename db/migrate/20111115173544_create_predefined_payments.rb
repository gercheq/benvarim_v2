class CreatePredefinedPayments < ActiveRecord::Migration
  def self.up
    create_table :predefined_payments do |t|
      t.integer :project_id
      t.string :name
      t.string :description
      t.boolean :disabled
      t.boolean :deleted

      t.timestamps
    end
  end

  def self.down
    drop_table :predefined_payments
  end
end
