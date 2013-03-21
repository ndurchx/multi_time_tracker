class CreateLoggedTimes < ActiveRecord::Migration
  def change
    create_table :logged_times do |t|
      t.integer :user_id, :null => false
      t.integer :project_id, :null => false
      t.integer :issue_id, :null => false
      t.integer :activity_id
      t.text :comment, :default => ""
      t.boolean :active, :null => false
      t.datetime :activated_at
      t.integer :spent_seconds, :default => 0
    end
  end
end
