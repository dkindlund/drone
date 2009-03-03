class UrlStatusesController < ApplicationController
  # GET /url_statuses
  # GET /url_statuses.xml
  def index
    @url_statuses = UrlStatus.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @url_statuses }
    end
  end

  # GET /url_statuses/1
  # GET /url_statuses/1.xml
  def show
    @url_status = UrlStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @url_status }
    end
  end

  # GET /url_statuses/new
  # GET /url_statuses/new.xml
  def new
    @url_status = UrlStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @url_status }
    end
  end

  # GET /url_statuses/1/edit
  def edit
    @url_status = UrlStatus.find(params[:id])
  end

  # POST /url_statuses
  # POST /url_statuses.xml
  def create
    @url_status = UrlStatus.new(params[:url_status])

    respond_to do |format|
      if @url_status.save
        flash[:notice] = 'UrlStatus was successfully created.'
        format.html { redirect_to(@url_status) }
        format.xml  { render :xml => @url_status, :status => :created, :location => @url_status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @url_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /url_statuses/1
  # PUT /url_statuses/1.xml
  def update
    @url_status = UrlStatus.find(params[:id])

    respond_to do |format|
      if @url_status.update_attributes(params[:url_status])
        flash[:notice] = 'UrlStatus was successfully updated.'
        format.html { redirect_to(@url_status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @url_status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /url_statuses/1
  # DELETE /url_statuses/1.xml
  def destroy
    @url_status = UrlStatus.find(params[:id])
    @url_status.destroy

    respond_to do |format|
      format.html { redirect_to(url_statuses_url) }
      format.xml  { head :ok }
    end
  end
end
