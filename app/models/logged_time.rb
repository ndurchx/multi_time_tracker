class LoggedTime < ActiveRecord::Base
  unloadable
  
  attr_accessible :activity_id, :comment
  
  belongs_to :project
  belongs_to :issue
  belongs_to :user
  
  validates_presence_of :issue_id, :user_id, :project_id
  
end
