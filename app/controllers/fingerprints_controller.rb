class FingerprintsController < ApplicationController
  # GET /fingerprints
  # GET /fingerprints.xml
  def index
    @fingerprints = Fingerprint.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fingerprints }
    end
  end

  # GET /fingerprints/1
  # GET /fingerprints/1.xml
  def show
    @fingerprint = Fingerprint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fingerprint }
    end
  end

  # GET /fingerprints/new
  # GET /fingerprints/new.xml
  def new
    @fingerprint = Fingerprint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fingerprint }
    end
  end

  # GET /fingerprints/1/edit
  def edit
    @fingerprint = Fingerprint.find(params[:id])
  end

  # POST /fingerprints
  # POST /fingerprints.xml
  def create
    @fingerprint = Fingerprint.new(params[:fingerprint])

    respond_to do |format|
      if @fingerprint.save
        flash[:notice] = 'Fingerprint was successfully created.'
        format.html { redirect_to(@fingerprint) }
        format.xml  { render :xml => @fingerprint, :status => :created, :location => @fingerprint }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fingerprint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fingerprints/1
  # PUT /fingerprints/1.xml
  def update
    @fingerprint = Fingerprint.find(params[:id])

    respond_to do |format|
      if @fingerprint.update_attributes(params[:fingerprint])
        flash[:notice] = 'Fingerprint was successfully updated.'
        format.html { redirect_to(@fingerprint) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fingerprint.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fingerprints/1
  # DELETE /fingerprints/1.xml
  def destroy
    @fingerprint = Fingerprint.find(params[:id])
    @fingerprint.destroy

    respond_to do |format|
      format.html { redirect_to(fingerprints_url) }
      format.xml  { head :ok }
    end
  end
end
