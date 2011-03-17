class CreatePaypalInfos < ActiveRecord::Migration
  def self.up
    create_table :paypal_infos do |t|
      t.integer :organization_id
      t.string :paypal_user
      t.string :paypal_id_token
      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_infos
  end
end
