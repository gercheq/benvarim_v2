class DeviseCreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table(:organizations) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.token_authenticatable

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

  def self.down
    drop_table :organizations
  end
end
