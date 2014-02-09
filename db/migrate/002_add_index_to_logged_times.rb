class AddIndexToLoggedTimes < ActiveRecord::Migration
  def change
    change_table :logged_times do |t|
      t.integer :index, :default => 0
    end
  end
end
