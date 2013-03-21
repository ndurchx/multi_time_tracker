require_dependency 'multi_time_tracker/hooks'

Redmine::Plugin.register :multi_time_tracker do
  name 'Multi Time Tracker plugin'
  author 'Kevin Neuenfeldt'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.enervision.eu'
  author_url ''

	requires_redmine :version_or_higher => '2.0.0'

  permission :add_issue_to_multi_time_tracker, { :multi_time_tracker => :create }
  menu :top_menu, :multi_time_tracker, { :controller => 'multi_time_tracker', :action => 'index' }, :caption => :caption_multi_time_tracker, :if => Proc.new{ User.current.logged? }
end
