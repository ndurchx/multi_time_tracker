# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match '/multi_time_tracker' => 'multi_time_tracker#index'
match '/multi_time_tracker/form' => 'multi_time_tracker#form'
match 'multi_time_tracker/export_all' => 'multi_time_tracker#export_all'
match '/multi_time_tracker/:issue_id' => 'multi_time_tracker#create', :as => :create_time_tracker

