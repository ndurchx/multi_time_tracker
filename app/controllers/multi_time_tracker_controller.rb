class MultiTimeTrackerController < ApplicationController
  unloadable

  before_filter :user_logged_in
  before_filter :find_logged_time, :only => [:edit, :destroy, :export]
  before_filter :find_project, :only => :add
  before_filter :is_time_tracking_active?, :only => :add

  helper :timelog

  def index
    @tracked_times = LoggedTime.find_all_by_user_id(User.current.id)
    @tracked_times.sort!{|x,y| x.project_id <=> y.project_id}
  end

  def add
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

  def edit
    logged_time = LoggedTime.find(params[:id])
    redirect_to :action => :index  if logged_time.active
  end

  def update
    @logged_time = LoggedTime.find(params[:logged_time][:id])
    @logged_time.spent_seconds = params[:logged_time][:spent_seconds]

    respond_to do |format|
      if @logged_time.update_attributes(params[:logged_time])
        flash[:notice] = l(:multi_time_tracker_update_successful)
      else
        flash[:error] = l(:multi_time_tracker_update_unsuccessful)
      end
      format.html { redirect_to :action => :index }
    end
  end

  def destroy
    check_out_logging(@logged_time) if @logged_time.active

    respond_to do |format|
      if export_to_timelog(@logged_time) && @logged_time.destroy
        flash[:notice] = l(:multi_time_tracker_destroy_successful)
      else
        flash[:error] = l(:multi_time_tracker_destroy_unsuccessful)
      end
      format.html { redirect_to :action => :index }
    end
  end

  def check_in_out
    @logged_time = LoggedTime.find_by_id(params[:logged_time][:id])

    if @logged_time.active
      check_out_logging(@logged_time)
    else
      current_checked_in = LoggedTime.find_by_user_id_and_active(User.current.id, true)

      unless current_checked_in.nil?
        check_out_logging(current_checked_in)
        current_checked_in.save
      end

      @logged_time.touch(:activated_at)
      @logged_time.active       = true
      @logged_time.activity_id  = params[:logged_time][:activity_id]
      @logged_time.comment      = params[:logged_time][:comment]
    end

    respond_to do |format|
      if @logged_time.save
        if @logged_time.active
          flash[:notice] = l(:multi_time_tracker_check_in_successful)
        else
          flash[:notice] = l(:multi_time_tracker_check_out_successful)
        end
      else
        flash[:error] = l(:multi_time_tracker_check_in_out_unsuccessful)
      end

      format.html { redirect_to :action => :index }
    end
  end

  def export_all
    logged_times = LoggedTime.find_all_by_user_id(User.current.id)
    error        = false

    logged_times.each do |time|
      check_out_logging(time) if time.active
      if export_to_timelog(time)
        reset(time)
      else
        error = true
      end
    end

    respond_to do |format|
      if error
        flash[:notice] = l(:multi_time_tracker_export_all_unsuccessful)
      else
        flash[:notice] = l(:multi_time_tracker_export_all_successful)
      end

      format.html { redirect_to :action => :index }
    end
  end

  def export
    check_out_logging(@logged_time) if @logged_time.active

    respond_to do |format|
      if export_to_timelog(@logged_time)
        reset(@logged_time)
        flash[:notice] = l(:multi_time_tracker_export_successful)
      else
        flash[:error] = l(:multi_time_tracker_export_unsuccessful)
      end

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

  def find_logged_time
    @logged_time = LoggedTime.find_by_id(params[:id])
  end

  def user_logged_in
    unless User.current.logged?
      flash[:error] = l(:multi_time_tracker_user_not_logged_in)
      redirect_to :home
    end
  end

  def check_out_logging(logged_time)
    logged_time.active = false
    logged_time.spent_seconds += (Time.now.to_f - logged_time.activated_at.to_f).to_i
  end

  def export_to_timelog(logged_time)
    return false if logged_time.project.module_enabled?(:time_tracking).nil?
    spent_hours = logged_time.spent_seconds/60.0/60.0

    if spent_hours > 0.008
      time_entry = TimeEntry.new(:project => logged_time.project, :issue => logged_time.issue, :user => logged_time.user, :spent_on => User.current.today)
      time_entry.safe_attributes = { "spent_on" => User.current.today, "hours" => spent_hours, "activity_id" => logged_time.activity_id, "comments" => logged_time.comment }
      return time_entry.save
    end

    return true
  end

  def reset(logged_time)
    logged_time.spent_seconds = 0
    logged_time.comment = ""
    logged_time.save
  end

  def is_time_tracking_active?
    if (@project.module_enabled? :time_tracking).nil?
      flash[:error] = l(:multi_time_tracker_time_tracking_inactive)
      redirect_to request.referer
    end
  end

end
