class JobAlertsController < ApplicationController
  # GET /job_alerts
  # GET /job_alerts.xml
  def index
    @job_alerts = JobAlert.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @job_alerts }
    end
  end

  # GET /job_alerts/1
  # GET /job_alerts/1.xml
  def show
    @job_alert = JobAlert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job_alert }
    end
  end

  # GET /job_alerts/new
  # GET /job_alerts/new.xml
  def new
    @job_alert = JobAlert.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job_alert }
    end
  end

  # GET /job_alerts/1/edit
  def edit
    @job_alert = JobAlert.find(params[:id])
  end

  # POST /job_alerts
  # POST /job_alerts.xml
  def create
    @job_alert = JobAlert.new(params[:job_alert])

    respond_to do |format|
      if @job_alert.save
        flash[:notice] = 'JobAlert was successfully created.'
        format.html { redirect_to(@job_alert) }
        format.xml  { render :xml => @job_alert, :status => :created, :location => @job_alert }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /job_alerts/1
  # PUT /job_alerts/1.xml
  def update
    @job_alert = JobAlert.find(params[:id])

    respond_to do |format|
      if @job_alert.update_attributes(params[:job_alert])
        flash[:notice] = 'JobAlert was successfully updated.'
        format.html { redirect_to(@job_alert) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /job_alerts/1
  # DELETE /job_alerts/1.xml
  def destroy
    @job_alert = JobAlert.find(params[:id])
    @job_alert.destroy

    respond_to do |format|
      format.html { redirect_to(job_alerts_url) }
      format.xml  { head :ok }
    end
  end
end
