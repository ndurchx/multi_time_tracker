# Patches Redmine's UserPreferences dynamically.
module MultiTimeTracker
  module Patches
    module UserPreferencePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          safe_attributes 'add_new_issues_to_multi_time_tracker_enabled'
        end
      end
    end
  end
end
