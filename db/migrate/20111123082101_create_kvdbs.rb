class CreateKvdbs < ActiveRecord::Migration
  def self.up
    create_table :kvdbs,:force => true, :id => false do |t|
      t.string :key, :limit => 128, :primary => true
      t.text :value
      t.datetime :expires, :default => nil

      t.timestamps
    end
  end

  def self.down
    drop_table :kvdbs
  end
end
