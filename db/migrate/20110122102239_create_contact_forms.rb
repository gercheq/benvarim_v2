class CreateContactForms < ActiveRecord::Migration
  def self.up
    create_table :contact_forms do |t|
      t.string :name
      t.string :city
      t.string :phone
      t.string :email
      t.string :organization
      t.string :organization_role
      t.text :other

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_forms
  end
end
