class UrlStatisticsController < ApplicationController
  # GET /url_statistics
  # GET /url_statistics.xml
  def index
    @url_statistics = UrlStatistic.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @url_statistics }
    end
  end

  # GET /url_statistics/1
  # GET /url_statistics/1.xml
  def show
    @url_statistic = UrlStatistic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @url_statistic }
    end
  end

  # GET /url_statistics/new
  # GET /url_statistics/new.xml
  def new
    @url_statistic = UrlStatistic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @url_statistic }
    end
  end

  # GET /url_statistics/1/edit
  def edit
    @url_statistic = UrlStatistic.find(params[:id])
  end

  # POST /url_statistics
  # POST /url_statistics.xml
  def create
    @url_statistic = UrlStatistic.new(params[:url_statistic])

    respond_to do |format|
      if @url_statistic.save
        flash[:notice] = 'UrlStatistic was successfully created.'
        format.html { redirect_to(@url_statistic) }
        format.xml  { render :xml => @url_statistic, :status => :created, :location => @url_statistic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @url_statistic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /url_statistics/1
  # PUT /url_statistics/1.xml
  def update
    @url_statistic = UrlStatistic.find(params[:id])

    respond_to do |format|
      if @url_statistic.update_attributes(params[:url_statistic])
        flash[:notice] = 'UrlStatistic was successfully updated.'
        format.html { redirect_to(@url_statistic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @url_statistic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /url_statistics/1
  # DELETE /url_statistics/1.xml
  def destroy
    @url_statistic = UrlStatistic.find(params[:id])
    @url_statistic.destroy

    respond_to do |format|
      format.html { redirect_to(url_statistics_url) }
      format.xml  { head :ok }
    end
  end
end
