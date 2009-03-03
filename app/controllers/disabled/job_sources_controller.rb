class JobSourcesController < ApplicationController
  # GET /job_sources
  # GET /job_sources.xml
  def index
    @job_sources = JobSource.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @job_sources }
    end
  end

  # GET /job_sources/1
  # GET /job_sources/1.xml
  def show
    @job_source = JobSource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job_source }
    end
  end

  # GET /job_sources/new
  # GET /job_sources/new.xml
  def new
    @job_source = JobSource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job_source }
    end
  end

  # GET /job_sources/1/edit
  def edit
    @job_source = JobSource.find(params[:id])
  end

  # POST /job_sources
  # POST /job_sources.xml
  def create
    @job_source = JobSource.new(params[:job_source])

    respond_to do |format|
      if @job_source.save
        flash[:notice] = 'JobSource was successfully created.'
        format.html { redirect_to(@job_source) }
        format.xml  { render :xml => @job_source, :status => :created, :location => @job_source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /job_sources/1
  # PUT /job_sources/1.xml
  def update
    @job_source = JobSource.find(params[:id])

    respond_to do |format|
      if @job_source.update_attributes(params[:job_source])
        flash[:notice] = 'JobSource was successfully updated.'
        format.html { redirect_to(@job_source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /job_sources/1
  # DELETE /job_sources/1.xml
  def destroy
    @job_source = JobSource.find(params[:id])
    @job_source.destroy

    respond_to do |format|
      format.html { redirect_to(job_sources_url) }
      format.xml  { head :ok }
    end
  end
end
