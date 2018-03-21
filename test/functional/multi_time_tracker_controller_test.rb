require File.expand_path('../../test_helper', __FILE__)

class MultiTimeTrackerControllerTest < ActionController::TestCase
  fixtures :logged_times, :projects, :users, :issues, 
          :enumerations, :enabled_modules

  def setup
    @request.session[:user_id] = 1
  end

  def test_index_shows_users_times
    @request.session[:user_id] = 1
    lt = LoggedTime.where(user_id: 1)
    get(:index)
    assert_response(:success)
    assert_not_nil(lt)
    assert_not_nil(assigns(:user))
    assert_not_nil(assigns(:tracked_times))
    assert_equal(assigns(:tracked_times).size, lt.size)
    assert_select('#tracked_times') do |tr|
      assert_select('tr', lt.size)
    end
  end

  def test_update 
    lt = {logged_time: {id: 1, spent_hours_short: 0.6, comment: 'New comment', activity_id: 9}}
    put(:update, id: 1, logged_time: {id: 1, spent_hours_short: 0.6, comment: 'New comment', activity_id: 9})
    assert_redirected_to('/multi_time_tracker')
    assert_equal(I18n.translate('multi_time_tracker_update_successful'), flash[:notice])
    nlt = LoggedTime.find(1)
    assert_equal(0.6, nlt.spent_hours)
    assert_equal('New comment', nlt.comment)
    assert_equal(9, nlt.activity_id)
  end

  def test_check_in_checks_current_out
    post(:action, check_in: 'CheckIn', logged_time: {id: 2, comment: 'New comment', activity_id: 9})
    lt = LoggedTime.find(1)
    assert_redirected_to('/multi_time_tracker')
    assert_not(lt.active)
  end

  def test_check_in_checks_new_in
    post(:action, check_in: 'CheckIn', logged_time: {id: 3, comment: 'New comment', activity_id: 9})
    lt = LoggedTime.find(3)
    assert_redirected_to('/multi_time_tracker')
    assert(lt.active)
  end

  def test_check_out_checks_current_out
    post(:action, check_out: 'CheckOut', logged_time: {id: 1, comment: 'New comment', activity_id: 9})
    lt = LoggedTime.find(1)
    assert_redirected_to('/multi_time_tracker')
    assert_not(lt.active)
  end

  def test_export_resets_data_and_checks_out
    post(:action, export: 'export', logged_time: {id: 1, comment: 'Old comment', activity_id: 9})
    assert_redirected_to('/multi_time_tracker')
    assert_not_nil(assigns(:logged_time))
    assert_not(assigns(:logged_time).active)
    assert_equal(0, assigns(:logged_time).spent_hours)
  end

  def test_delete
    post(:action, destroy: 'destroy', logged_time: {id: 1, comment: 'Old comment', activity_id: 9})
    lt = LoggedTime.find_by_id(1)
    assert_redirected_to('/multi_time_tracker')
    assert_nil(lt)
  end
end
