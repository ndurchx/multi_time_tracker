class LoggedTime < ActiveRecord::Base
  unloadable
  
  attr_accessible :activity_id, :comment
  
  belongs_to :project
  belongs_to :issue
  belongs_to :user
  belongs_to :activity
  
  validates_presence_of :issue_id, :user_id, :project_id
  validates :spent_seconds, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
    
  def reset
    self.spent_seconds = 0
    self.comment = ""
  end
  
  def check_out
    return unless self.active
    self.active = false
    self.spent_seconds += (Time.now.to_f - self.activated_at.to_f).to_i
  end
  
  def check_in(arg_hash)
    return if self.active
    self.touch(:activated_at)
    self.active       = true
    self.activity_id  = arg_hash[:activity_id]
    self.comment      = arg_hash[:comment]
  end
  
  def self.current
    self.find_by_user_id_and_active(User.current.id, true)
  end
  
  def export
    return false if self.project.module_enabled?(:time_tracking).nil?
    spent_hours = self.spent_seconds/60.0/60.0

    if spent_hours > 0.008
      time_entry = TimeEntry.new(:project => self.project, :issue => self.issue, :user => self.user, :spent_on => User.current.today)
      time_entry.safe_attributes = { "spent_on" => User.current.today, "hours" => spent_hours, "activity_id" => self.activity_id, "comments" => self.comment }
      return time_entry.save
    end
    
    true
  end
  
end
