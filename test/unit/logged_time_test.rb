require File.expand_path('../../test_helper', __FILE__)

class LoggedTimeTest < ActiveSupport::TestCase
  fixtures :logged_times, :custom_fields,
           :issues, :projects, :users, :time_entries,
           :members, :roles, :member_roles,
           :trackers, :issue_statuses,
           :projects_trackers,
           :journals, :journal_details,
           :issue_categories, :enumerations,
           :groups_users,
           :enabled_modules

  def test_presence_of_issue_id
    lt = LoggedTime.new(activity: Enumeration.find(9), comment: 'Working on unit tests')
    lt.project = Project.first
    lt.user = User.first
    assert_not(lt.save)
  end

  def test_presence_of_user_id
    lt = LoggedTime.new(activity: Enumeration.find(9), comment: 'Working on unit tests')
    lt.project = Project.first
    lt.issue = Issue.first
    assert_not(lt.save)
  end

  def test_presence_of_project_id
    lt = LoggedTime.new(activity: Enumeration.find(9), comment: 'Working on unit tests')
    lt.issue = Issue.first
    lt.user = User.first
    assert_not(lt.save)
  end

  def test_numericality_spent_hours
    lt = LoggedTime.new(activity: Enumeration.find(9), comment: 'Working on unit tests')
    lt.issue = Issue.first
    lt.user = User.first
    lt.spent_hours = -1
    assert_not(lt.save)
  end

  def test_check_out_successful
    lt = LoggedTime.find(1)
    diff = lt.spent_hours + ((Time.now.to_f - lt.activated_at.to_f)/60.0/60.0)
    assert(lt.active)
    lt.check_out
    assert_in_delta(diff, lt.spent_hours, 0.00027)
    assert_not(lt.active)
  end

  def test_check_out_not_possible_if_checked_out
    lt = LoggedTime.find(2)
    assert_not(lt.active)
    assert_no_difference('lt.spent_hours') do
      lt.check_out  
    end    
    assert_not(lt.active)
  end

  def test_check_in_successful  
    lt = LoggedTime.find(2)
    assert_not(lt.active)
    lt.check_in(activity_id: 9, comment: 'Testcomment')
    assert_in_delta(Time.now, lt.activated_at, 2)
    assert(lt.active)
  end

  def test_check_in_not_possible_if_checked_in
    lt = LoggedTime.find(1)    
    assert(lt.active)
    assert_no_difference(['lt.activated_at', 'lt.activity_id']) do
      lt.check_in(activity_id: 9, comment: 'Testcomment')
    end
    assert(lt.active)
  end

  def test_export_requires_time_tracking_module
    lt = LoggedTime.find(3)
    assert_no_difference('TimeEntry.count') do
      lt.export(User.anonymous)
    end
    assert_include(I18n.translate('multi_time_tracker_time_tracking_inactive'), lt.errors[:project])
    assert_equal(lt.errors.size, 1)
  end

  def test_export_requires_spent_hours
    lt = LoggedTime.find(4)
    assert_no_difference('TimeEntry.count') do
      lt.export(User.anonymous)
    end
    assert_include(I18n.translate('multi_time_tracker_spent_hours_greater_zero'), lt.errors[:spent_hours_short])
    assert_equal(lt.errors.size, 1)
  end

  def test_export_creates_time_entry
    lt = LoggedTime.find(2)
    assert_difference('TimeEntry.count') do
      lt.export(User.anonymous)
    end
  end
end
