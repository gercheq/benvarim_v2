class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :address
      t.date :birthday
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.token_authenticatable


      # t.confirmable, t.trackable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      #


      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
