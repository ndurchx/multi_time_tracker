require File.expand_path('../../test_helper', __FILE__)

class MultiTimeTrackerFlowsTest < Redmine::IntegrationTest
  fixtures :logged_times, :projects, :users, :issues, 
          :enumerations, :enabled_modules, :time_entries

  def setup
    log_user('admin', 'admin')
  end

  def test_export_creates_correct_time_entry
    lt = LoggedTime.find(2)
    assert_difference 'TimeEntry.count' do
      post('/multi_time_tracker/action', export: 'export', logged_time: {id: 2, comment: 'New comment', activity_id: 9})
    end
    lt_new = assigns(:logged_time)
    te = TimeEntry.last
    assert_equal(lt.issue_id,    te.issue_id)
    assert_equal(lt.user_id,     te.user_id)
    assert_equal(lt.project_id,  te.project_id)
    assert_equal(lt.activity_id, te.activity_id)
    assert_equal("New comment",  te.comments)
    assert_equal(lt.spent_hours, te.hours)
  end

  def test_export_all_creates_correct_time_entry
    lts = LoggedTime.where('spent_hours > 0').where(project_id: [1,3], user_id: 1)
    assert_difference('TimeEntry.count', lts.length) do
      post('/multi_time_tracker/export_all')
    end    
  end  
end