class AddUserPreference < ActiveRecord::Migration
  def self.up
    add_column :user_preferences, :add_new_issues_to_multi_time_tracker_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :user_preferences, :add_new_issues_to_multi_time_tracker_enabled
  end
end
