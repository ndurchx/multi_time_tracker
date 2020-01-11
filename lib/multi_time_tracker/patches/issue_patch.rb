module MultiTimeTracker
  module Patches
    module IssuePatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          after_destroy :remove_tracked_times_for_issue
      	  after_update :update_tracked_times_for_issue
      	  after_create :add_issue_to_time_tracker
        end
      end

      module InstanceMethods

        def remove_tracked_times_for_issue
          tracked_times = LoggedTime.destroy_all(user_id: User.current.id, issue_id: self.id)
        end

        def update_tracked_times_for_issue
          tracked_times = LoggedTime.where(user_id: User.current.id, issue_id: self.id)
          tracked_times.each do |time|
            time.project_id = self.project.id
            time.save
          end
        end

        def add_issue_to_time_tracker
          if User.current.pref[:add_new_issues_to_multi_time_tracker_enabled]
            logged_time = LoggedTime.new
            logged_time.issue_id = self.id
            logged_time.user_id = User.current.id
            logged_time.project_id = self.project.id
            logged_time.active = false
            logged_time.save
          end
        end

      end

    end
  end
end
