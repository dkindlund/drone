class UrlsController < ApplicationController
  # GET /urls
  # GET /urls.xml
  def index
    @urls = Url.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @urls }
    end
  end

  # GET /urls/1
  # GET /urls/1.xml
  def show
    @url = Url.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @url }
    end
  end

  # GET /urls/new
  # GET /urls/new.xml
  def new
    @url = Url.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @url }
    end
  end

  # GET /urls/1/edit
  def edit
    @url = Url.find(params[:id])
  end

  # POST /urls
  # POST /urls.xml
  def create
    @url = Url.new(params[:url])

    respond_to do |format|
      if @url.save
        flash[:notice] = 'Url was successfully created.'
        format.html { redirect_to(@url) }
        format.xml  { render :xml => @url, :status => :created, :location => @url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /urls/1
  # PUT /urls/1.xml
  def update
    @url = Url.find(params[:id])

    respond_to do |format|
      if @url.update_attributes(params[:url])
        flash[:notice] = 'Url was successfully updated.'
        format.html { redirect_to(@url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.xml
  def destroy
    @url = Url.find(params[:id])
    @url.destroy

    respond_to do |format|
      format.html { redirect_to(urls_url) }
      format.xml  { head :ok }
    end
  end
end
