class JobController < ApplicationController

  def define
    @project = Project.find(params[:id])
    @sfiles = Sfile.find_all_by_project_id(@project.id)
  end
  
  def select_files
    if params['cancel']
      redirect_to(:controller => "project", :action => "show", :id => params[:job][:project_id])
    else
      @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    end
  end

  def delete
    @job = Job.find(params[:id])
    @job.destroy
    flash[:notice] = "Job #{@job.name} successfully deleted."
    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
  end

  
  def create
    if params['cancel']
      redirect_to(:controller => "project", :action => "show", :id => params[:job][:project_id])
      return
    end

    @job = Job.new(params[:job])

    if @job.save
      begin
        @job.start
        flash[:notice] = "Job #{@job.name} successfully created and started."
        redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
        return
      rescue
        @job.destroy
        # don't need to show flash message if errors exist
        flash[:notice] = "Job #{@job.name} could not be started." if @job.errors.empty?
      end
    end

    @project = Project.find(@job.project_id)
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    render(:action => "define")
  end

  def show_color
    @job = Job.find_by_id(params[:id])
  end

  def color_kml
    puts params
    @job = Job.find_by_id(params[:id])

    if params['cancel']
      redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
      return
    end

    if @job.update_attributes(params[:job])
      @job.create_colored_kml
      redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
      return
    else
      render :show_color
    end
  end
end
