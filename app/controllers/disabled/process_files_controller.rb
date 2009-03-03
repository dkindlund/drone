class ProcessFilesController < ApplicationController
  # GET /process_files
  # GET /process_files.xml
  def index
    @process_files = ProcessFile.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_files }
    end
  end

  # GET /process_files/1
  # GET /process_files/1.xml
  def show
    @process_file = ProcessFile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_file }
    end
  end

  # GET /process_files/new
  # GET /process_files/new.xml
  def new
    @process_file = ProcessFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_file }
    end
  end

  # GET /process_files/1/edit
  def edit
    @process_file = ProcessFile.find(params[:id])
  end

  # POST /process_files
  # POST /process_files.xml
  def create
    @process_file = ProcessFile.new(params[:process_file])

    respond_to do |format|
      if @process_file.save
        flash[:notice] = 'ProcessFile was successfully created.'
        format.html { redirect_to(@process_file) }
        format.xml  { render :xml => @process_file, :status => :created, :location => @process_file }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_files/1
  # PUT /process_files/1.xml
  def update
    @process_file = ProcessFile.find(params[:id])

    respond_to do |format|
      if @process_file.update_attributes(params[:process_file])
        flash[:notice] = 'ProcessFile was successfully updated.'
        format.html { redirect_to(@process_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_files/1
  # DELETE /process_files/1.xml
  def destroy
    @process_file = ProcessFile.find(params[:id])
    @process_file.destroy

    respond_to do |format|
      format.html { redirect_to(process_files_url) }
      format.xml  { head :ok }
    end
  end
end
