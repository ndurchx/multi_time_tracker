require_dependency 'multi_time_tracker/hooks'

ActiveSupport::Reloader.to_prepare do
  Issue.send(:include, MultiTimeTracker::Patches::IssuePatch)
  UserPreference.send(:include, MultiTimeTracker::Patches::UserPreferencePatch)
end

Redmine::Plugin.register :multi_time_tracker do
  name 'Multi Time Tracker'
  author 'Kevin Neuenfeldt'
  description 'This plugin adds a new time related functionality to your redmine. Logged in users with appropriate permission
  will be able to add entries for issues to the Multi Time Tracker by clicking a link in issues view. If the user is allowed to make
  entries to time log, he will even be able to export his tracked times to it. And don\'t be scared, all actions are fail save.'
  version '0.2.0'
  url 'https://github.com/raafael911/multi_time_tracker'
  author_url ''

	requires_redmine :version_or_higher => '4.0.0'

  menu :top_menu, :multi_time_tracker, { :controller => 'multi_time_tracker', :action => 'index' }, :caption => :caption_multi_time_tracker, :if => Proc.new{ User.current.logged? }
end
