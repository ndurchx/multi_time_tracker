class MultiTimeTrackerController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => :create
  before_filter :find_checked_in_logger, :except => [:create, :index, :correct, :export_all]

  def index
    @tracked_times = LoggedTime.find_all_by_user_id(User.current.id)
    @tracked_times.sort!{|x,y| x.project_id <=> y.project_id}
  end

  def create
    @logged_time = LoggedTime.new
    @logged_time.issue_id = @issue.id
    @logged_time.user_id = User.current.id
    @logged_time.project_id = @project.id
    @logged_time.activity_id = nil
    @logged_time.comment = ""
    @logged_time.active = false
    @logged_time.activated_at = nil
    @logged_time.spent_seconds = 0
    
    respond_to do |format|
      if @logged_time.save
        flash[:notice] = l(:multi_time_tracker_tracking_successfully_created)
      else
        flash[:error] = l(:multi_time_tracker_tracking_not_created)
      end
      format.html { redirect_to :action => :index }
    end
  end
  
  def form
    case params[:commit]
      when l(:multi_time_tracker_check_in_button)
        check_in
      when l(:multi_time_tracker_check_out_button)
        check_out
      when l(:multi_time_tracker_destroy_button)
        destroy
      else 
        respond_to do |format|
          flash[:error] = l(:multi_time_tracker_form_action_error)
          format.html { redirect_to :action => :index }
        end
    end
  end

  def destroy
    if @logged_time.active
      check_out_logging(@logged_time)
    end
    
    export(@logged_time)
    
    respond_to do |format|
      if @logged_time.destroy
        flash[:notice] = l(:multi_time_tracker_destroy_successful)
      else
        flash[:error] = l(:multi_time_tracker_destroy_unsuccessful)
      end
      format.html { redirect_to :action => :index }
    end
  end

  def check_in
    unless @logged_time.active    
      @logged_time.touch(:activated_at)
      current_checked_in = LoggedTime.find_by_user_id_and_active(User.current.id, true)
      check_out_logging(current_checked_in) unless current_checked_in.nil?
      current_checked_in.save unless current_checked_in.nil?
      @logged_time.active = true
    end
    
    @logged_time.activity_id = params[:logged_time][:activity_id]
    @logged_time.comment = params[:logged_time][:comment]
    
    respond_to do |format|
      if @logged_time.save
        flash[:notice] = l(:multi_time_tracker_check_in_successful)
      else
        flash[:error] = l(:multi_time_tracker_check_in_unsuccessful)
      end
      format.html { redirect_to :action => :index }
    end
  end

  def check_out
    if @logged_time.active
      check_out_logging(@logged_time)
          
      respond_to do |format|
        if @logged_time.save
          flash[:notice] = l(:multi_time_tracker_check_out_successful)
        else
          flash[:error] = l(:multi_time_tracker_check_out_unsuccessful)
        end
        format.html { redirect_to :action => :index }
      end
    else
      respond_to do |format|
        flash[:error] = l(:multi_time_tracker_check_out_not_checked_in)
        format.html { redirect_to :action => :index }
      end
    end
  end

  def export_all
    logged_times = LoggedTime.find_all_by_user_id(User.current.id)
    
    logged_times.each do |time|
      check_out_logging(time) if time.active
      export(time)
      reset(time)
    end
    
    respond_to do |format|
      flash[:notice] = l(:multi_time_tracker_export_all_successful)
      format.html { redirect_to :action => :index }
    end
  end

  def correct
  end
  
  
  private
  
  def find_project
    @issue = Issue.find_by_id(params[:issue_id])
    @project = Project.find_by_id(@issue.project_id)
    rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_checked_in_logger
    @logged_time = LoggedTime.find_by_id(params[:logged_time][:id])
  end
  
  def check_out_logging(logged_time)
    logged_time.active = false
    logged_time.spent_seconds += (Time.now.to_f - logged_time.activated_at.to_f)
  end
  
  def export(logged_time)
    spent_hours = logged_time.spent_seconds/60.0/60.0
    if spent_hours > 0
      time_entry = TimeEntry.new(:project => logged_time.project, :issue => logged_time.issue, :user => logged_time.user, :spent_on => User.current.today)
      time_entry.safe_attributes = { "spent_on" => User.current.today, "hours" => spent_hours, "activity_id" => logged_time.activity_id, "comments" => logged_time.comment }
      time_entry.save
    end
  end
  
  def check_presence_of_comment_and_activity
    
  end 
  
  def reset(logged_time)
    logged_time.spent_seconds = 0
    logged_time.comment = ""
    logged_time.save
  end
  
end
