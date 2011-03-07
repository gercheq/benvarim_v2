class DropOrganizationAuth < ActiveRecord::Migration
    def self.up
      drop_table :organizations
      create_table(:organizations) do |t|
        t.integer :user_id
        t.string :name
        t.string :address
        t.text :description
        t.boolean :approved, :default => false
        t.boolean :active, :default => false
      end
    end

    def self.down
      drop_table :organizations
      create_table(:organizations) do |t|
        t.database_authenticatable :null => false
        t.recoverable
        t.rememberable
        t.token_authenticatable
        t.integer :user_id
        t.string :name
        t.string :address
        t.text :description
        t.boolean :approved, :default => false
        t.boolean :active, :default => false

        # t.confirmable
        # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
        # t.trackable


        t.timestamps
      end

      add_index :organizations, :email,                :unique => true
      add_index :organizations, :reset_password_token, :unique => true
      # add_index :organizations, :confirmation_token,   :unique => true
      # add_index :organizations, :unlock_token,         :unique => true

    end
  end
