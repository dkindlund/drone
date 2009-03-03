class FileContentsController < ApplicationController
  # GET /file_contents
  # GET /file_contents.xml
  def index
    @file_contents = FileContent.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @file_contents }
    end
  end

  # GET /file_contents/1
  # GET /file_contents/1.xml
  def show
    @file_content = FileContent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @file_content }
    end
  end

  # GET /file_contents/new
  # GET /file_contents/new.xml
  def new
    @file_content = FileContent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @file_content }
    end
  end

  # GET /file_contents/1/edit
  def edit
    @file_content = FileContent.find(params[:id])
  end

  # POST /file_contents
  # POST /file_contents.xml
  def create
    @file_content = FileContent.new(params[:file_content])

    respond_to do |format|
      if @file_content.save
        flash[:notice] = 'FileContent was successfully created.'
        format.html { redirect_to(@file_content) }
        format.xml  { render :xml => @file_content, :status => :created, :location => @file_content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @file_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /file_contents/1
  # PUT /file_contents/1.xml
  def update
    @file_content = FileContent.find(params[:id])

    respond_to do |format|
      if @file_content.update_attributes(params[:file_content])
        flash[:notice] = 'FileContent was successfully updated.'
        format.html { redirect_to(@file_content) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @file_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /file_contents/1
  # DELETE /file_contents/1.xml
  def destroy
    @file_content = FileContent.find(params[:id])
    @file_content.destroy

    respond_to do |format|
      format.html { redirect_to(file_contents_url) }
      format.xml  { head :ok }
    end
  end
end
