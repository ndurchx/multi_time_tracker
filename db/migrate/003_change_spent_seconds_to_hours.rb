class ChangeSpentSecondsToHours < ActiveRecord::Migration
  def change
    change_table :logged_times do |t|
      t.remove :spent_seconds
      t.float :spent_hours, :default => 0
    end
  end
end
