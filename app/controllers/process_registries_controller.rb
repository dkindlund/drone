class ProcessRegistriesController < ApplicationController
  # GET /process_registries
  # GET /process_registries.xml
  def index
    @process_registries = ProcessRegistry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_registries }
    end
  end

  # GET /process_registries/1
  # GET /process_registries/1.xml
  def show
    @process_registry = ProcessRegistry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_registry }
    end
  end

  # GET /process_registries/new
  # GET /process_registries/new.xml
  def new
    @process_registry = ProcessRegistry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_registry }
    end
  end

  # GET /process_registries/1/edit
  def edit
    @process_registry = ProcessRegistry.find(params[:id])
  end

  # POST /process_registries
  # POST /process_registries.xml
  def create
    @process_registry = ProcessRegistry.new(params[:process_registry])

    respond_to do |format|
      if @process_registry.save
        flash[:notice] = 'ProcessRegistry was successfully created.'
        format.html { redirect_to(@process_registry) }
        format.xml  { render :xml => @process_registry, :status => :created, :location => @process_registry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @process_registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_registries/1
  # PUT /process_registries/1.xml
  def update
    @process_registry = ProcessRegistry.find(params[:id])

    respond_to do |format|
      if @process_registry.update_attributes(params[:process_registry])
        flash[:notice] = 'ProcessRegistry was successfully updated.'
        format.html { redirect_to(@process_registry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @process_registry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_registries/1
  # DELETE /process_registries/1.xml
  def destroy
    @process_registry = ProcessRegistry.find(params[:id])
    @process_registry.destroy

    respond_to do |format|
      format.html { redirect_to(process_registries_url) }
      format.xml  { head :ok }
    end
  end
end
