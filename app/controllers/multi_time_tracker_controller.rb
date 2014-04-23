class MultiTimeTrackerController < ApplicationController
  unloadable

  before_filter :user_logged_in
  before_filter :find_project, :only => :add
  before_filter :is_time_tracking_active?, :only => :add
  before_filter :find_logged_time, :only => [:action]
  before_filter :save_current_data, :only => [:action]
  

  helper :timelog
  
  def action
    if params[:check_in]
      check_in
    elsif params[:check_out]
      check_out
    elsif params[:destroy]
      destroy
    elsif params[:export]
      export
    end  
  end

  def index
    @tracked_times = LoggedTime.find_all_by_user_id(User.current.id)
    @user = User.current
  end

  def add
    @logged_time = LoggedTime.new
    @logged_time.issue_id = @issue.id
    @logged_time.user_id = User.current.id
    @logged_time.project_id = @project.id
    @logged_time.active = false

    respond_to do |format|
      if @logged_time.save
        flash[:notice] = l(:multi_time_tracker_tracking_successfully_created)
      else
        flash[:error] = l(:multi_time_tracker_tracking_not_created)
      end
      format.html { redirect_to :action => :index }
    end
  end
  
  def reorder
    LoggedTime.reorder_list(params[:logged_data])
    @tracked_times = LoggedTime.find_all_by_user_id(User.current.id)
    
    respond_to do |format|
      format.js {render :partial => "times_list"}
    end
  end

  def edit
    @logged_time = LoggedTime.find(params[:id])
    redirect_to :action => :index  if @logged_time.active
  end

  def update
    logged_time = LoggedTime.find(params[:logged_time][:id])
    logged_time.spent_hours   = params[:logged_time][:spent_hours_short]
    logged_time.comment       = params[:logged_time][:comment]
    logged_time.activity_id   = params[:logged_time][:activity_id]

    respond_to do |format|
      if logged_time.save
        flash[:notice] = l(:multi_time_tracker_update_successful)
      else
        flash[:error] = l(:multi_time_tracker_update_unsuccessful)
      end
      format.html { redirect_to :action => :index }
    end
  end

  def destroy
    @logged_time.check_out

    respond_to do |format|      
      if @logged_time.destroy
        flash[:notice] = l(:multi_time_tracker_destroy_successful)
        format.html { redirect_to :action => :index }
      else
        format.html { render :action => :edit }
      end
    end
  end
  
  def check_in
    current = LoggedTime.current
    current.check_out if current
    
    @logged_time.check_in(params[:logged_time])
    
    respond_to do |format|
      if (current.nil? || current.save) && @logged_time.save
        flash[:notice] = l(:multi_time_tracker_check_in_successful)
      else
        flash[:notice] = l(:multi_time_tracker_check_out_successful)
      end

      format.html { redirect_to :action => :index }
    end
  end
  
  def check_out
    @logged_time.check_out
    
    respond_to do |format|
      if @logged_time.save 
        flash[:notice] = l(:multi_time_tracker_check_out_successful)
      else
        flash[:notice] = l(:multi_time_tracker_check_out_successful)
      end
      
      format.html { redirect_to :action => :index }
    end
  end

  def export_all
    logged_times = LoggedTime.find_all_by_user_id(User.current.id)
    error        = false

    logged_times.each do |time|
      time.check_out
      if time.export
        time.reset
        time.save
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
    @logged_time.check_out

    respond_to do |format|
      if @logged_time.export
        @logged_time.reset and @logged_time.save        
        flash[:notice] = l(:multi_time_tracker_export_successful)
        format.html { redirect_to :action => :index }
        format.json { render :nothing => true }
      else
        format.html { render :action => :edit }
        format.json { render :action => :edit }        
      end
    end
  end

  private
  
  def save_current_data
    @logged_time.update_attributes(params[:logged_time])
  end

  def find_project
    @issue = Issue.find_by_id(params[:issue_id])
    @project = Project.find_by_id(@issue.project_id)
    rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_logged_time
    @logged_time = LoggedTime.find_by_id(params[:logged_time][:id])
    rescue ActiveRecord::RecordNotFound
    render_404
  end

  def user_logged_in
    unless User.current.logged?
      flash[:error] = l(:multi_time_tracker_user_not_logged_in)
      redirect_to :home
    end
  end

  def is_time_tracking_active?
    if (@project.module_enabled? :time_tracking).nil?
      flash[:error] = l(:multi_time_tracker_time_tracking_inactive)
      redirect_to request.referer
    end
  end

end
