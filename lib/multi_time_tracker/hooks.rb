module MultiTimeTracker
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, :partial => 'issues_view_patch'
    render_on :view_my_account_preferences, :partial => 'account_settings/multi_time_tracker_settings', :layout => false
  end
end
