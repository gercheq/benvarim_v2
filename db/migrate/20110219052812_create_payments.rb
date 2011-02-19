class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string :name
      t.text :note
      t.string :email
      t.integer :page_id
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
