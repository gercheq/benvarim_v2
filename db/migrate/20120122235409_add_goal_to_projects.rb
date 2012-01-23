class AddGoalToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :goal,    :float
  end

  def self.down
    remove_column :projects, :goal
  end
end
