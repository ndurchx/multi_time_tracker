require File.expand_path('../../test_helper', __FILE__)

class MultiTimeTrackerControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_check_in_and_out
		@request.session[:user_id] = 1
		get :index
		assert_response :success
		post(:check_in_out, { :logged_time => { :id => "7", :comment => "stuff", :activity_id => "8" }, :commit => "Check in" })
  end
end
