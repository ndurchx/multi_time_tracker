class LoggedTime < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :issue
  belongs_to :user
  belongs_to :activity, :foreign_key => "activity_id", :class_name => "TimeEntryActivity"

  validates_presence_of :issue_id, :user_id, :project_id
  validates :spent_hours, :numericality => { :greater_than_or_equal_to => 0 }

  def user_params
    params.require(:user).permit(:activity_id, :comment)
  end

  def reset
    self.spent_hours = 0
    self.comment = ""
  end

  def spent_hours=(s)
    write_attribute :spent_hours, (s.is_a?(String) ? (s.to_hours || s) : s)
  end

  def spent_hours_short
    h = read_attribute(:spent_hours)
    if h.is_a?(Float)
      h.round(4)
    else
      h
    end
  end

  def check_out
    return unless self.active
    self.active = false
    self.spent_hours += (Time.now.to_f - self.activated_at.to_f)/60.0/60.0
  end

  def check_in(arg_hash)
    return if self.active
    self.touch(:activated_at)
    self.active       = true
    self.activity     = TimeEntryActivity.find(arg_hash[:activity_id])
    self.comment      = arg_hash[:comment]
  end

  def self.current
    self.find_by_user_id_and_active(User.current.id, true)
  end

  def self.reorder_list(ids)
    logged_times = LoggedTime.where(user_id: User.current.id)
    logged_times.each do |time|
      time.index = ids.index{|x|x.to_i == time.id}
      time.save
    end
  end

  def export(usr=User.current)
    unless self.project.enabled_module_names.include?('time_tracking')
      errors.add(:project, l('multi_time_tracker_time_tracking_inactive'))
      return false
    end

    unless self.project.active?
      errors.add(:project, l('multi_time_tracker_project_inactive'))
      return false
    end

    if self.spent_hours == 0
      errors.add(:spent_hours_short, l('multi_time_tracker_spent_hours_greater_zero'))
      return false
    end

    return TimeEntry.create(:spent_on => self.user.today,
                          :hours    => self.spent_hours,
                          :issue    => self.issue,
                          :user     => self.user,
                          :activity => self.activity,
                          :comments => self.comment)
  end

  def is_used?
    return (self.spent_hours > 0 or self.active)
  end

end
