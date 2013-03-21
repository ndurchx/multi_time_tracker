module MultiTimeTracker
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, :partial => 'issues_view_patch'
  end
end
