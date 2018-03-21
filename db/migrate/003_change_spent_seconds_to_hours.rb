class ChangeSpentSecondsToHours < ActiveRecord::Migration
  def self.up
      remove_column(:logged_times, :spent_seconds)
      add_column(:logged_times, :spent_hours, :float, :default => 0)
  end

  def self.down
    add_column(:logged_times, :spent_seconds, :integer)
    remove_column(:logged_times, :spent_hours)
  end
end
