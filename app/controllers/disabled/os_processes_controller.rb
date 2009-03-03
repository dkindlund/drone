class OsProcessesController < ApplicationController
  # GET /os_processes
  # GET /os_processes.xml
  def index
    @os_processes = OsProcess.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @os_processes }
    end
  end

  # GET /os_processes/1
  # GET /os_processes/1.xml
  def show
    @os_process = OsProcess.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @os_process }
    end
  end

  # GET /os_processes/new
  # GET /os_processes/new.xml
  def new
    @os_process = OsProcess.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @os_process }
    end
  end

  # GET /os_processes/1/edit
  def edit
    @os_process = OsProcess.find(params[:id])
  end

  # POST /os_processes
  # POST /os_processes.xml
  def create
    @os_process = OsProcess.new(params[:os_process])

    respond_to do |format|
      if @os_process.save
        flash[:notice] = 'OsProcess was successfully created.'
        format.html { redirect_to(@os_process) }
        format.xml  { render :xml => @os_process, :status => :created, :location => @os_process }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @os_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /os_processes/1
  # PUT /os_processes/1.xml
  def update
    @os_process = OsProcess.find(params[:id])

    respond_to do |format|
      if @os_process.update_attributes(params[:os_process])
        flash[:notice] = 'OsProcess was successfully updated.'
        format.html { redirect_to(@os_process) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @os_process.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /os_processes/1
  # DELETE /os_processes/1.xml
  def destroy
    @os_process = OsProcess.find(params[:id])
    @os_process.destroy

    respond_to do |format|
      format.html { redirect_to(os_processes_url) }
      format.xml  { head :ok }
    end
  end
end
