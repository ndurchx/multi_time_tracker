module MultiTimeTracker
  module Patches
    module IssuePatch

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          after_destroy :remove_tracked_times_for_issue
        end
      end

      module ClassMethods

        def remove_tracked_times_for_issue
          tracked_times = LoggedTime.find_all_by_user_id_and_issue_id(User.current.id, self.id)
          tracked_times.each do |time|
            time.destroy
          end
        end

      end

      module InstanceMethods

        def remove_tracked_times_for_issue
          tracked_times = LoggedTime.find_all_by_user_id_and_issue_id(User.current.id, self.id)
          tracked_times.each do |time|
            time.destroy
          end
        end

      end

    end
  end
end