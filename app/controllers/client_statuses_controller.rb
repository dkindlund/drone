class ClientStatusesController < ApplicationController
  # GET /client_statuses
  # GET /client_statuses.xml
  def index
    @client_statuses = ClientStatus.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @client_statuses }
    end
  end

  # GET /client_statuses/1
  # GET /client_statuses/1.xml
  def show
    @client_status = ClientStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @client_status }
    end
  end

  # GET /client_statuses/new
  # GET /client_statuses/new.xml
  def new
    @client_status = ClientStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @client_status }
    end
  end

  # GET /client_statuses/1/edit
  def edit
    @client_status = ClientStatus.find(params[:id])
  end

  # POST /client_statuses
  # POST /client_statuses.xml
  def create
    @client_status = ClientStatus.new(params[:client_status])

    respond_to do |format|
      if @client_status.save
        flash[:notice] = 'ClientStatus was successfully created.'
        format.html { redirect_to(@client_status) }
        format.xml  { render :xml => @client_status, :status => :created, :location => @client_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @client_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /client_statuses/1
  # PUT /client_statuses/1.xml
  def update
    @client_status = ClientStatus.find(params[:id])

    respond_to do |format|
      if @client_status.update_attributes(params[:client_status])
        flash[:notice] = 'ClientStatus was successfully updated.'
        format.html { redirect_to(@client_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @client_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /client_statuses/1
  # DELETE /client_statuses/1.xml
  def destroy
    @client_status = ClientStatus.find(params[:id])
    @client_status.destroy

    respond_to do |format|
      format.html { redirect_to(client_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
