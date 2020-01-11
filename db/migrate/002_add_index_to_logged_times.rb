class AddIndexToLoggedTimes < ActiveRecord::Migration
	def self.up
		add_column(:logged_times, :index, :integer, :default => 0)
	end

	def self.down
		remove_column(:logged_times, :index)
	end
end
