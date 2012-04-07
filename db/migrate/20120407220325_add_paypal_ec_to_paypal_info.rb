class AddPaypalEcToPaypalInfo < ActiveRecord::Migration
  def self.up
    add_column :paypal_infos, :use_express, :boolean, :default => false
    add_column :paypal_infos, :express_info, :text, :default => nil
  end

  def self.down
    remove_column :paypal_infos, :use_express
    remove_column :paypal_infos, :express_info
  end
end
