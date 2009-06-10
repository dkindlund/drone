class UsersController < ApplicationController
  ssl_required :new, :create, :activate, :suspend, :unsuspend, :destroy, :purge, :render_field, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  
  before_filter :login_required, :except => [:new, :create, :activate]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  active_scaffold :user do |config|
    # Table Title
    config.list.label = "Users"

    # Show the following columns in the specified order.
    config.list.columns = [:name, :login, :email, :organization, :state, :roles, :created_at, :updated_at, :activated_at, :deleted_at]
    config.show.columns = [:name, :login, :email, :organization, :state, :roles, :groups, :created_at, :updated_at, :activated_at, :deleted_at]

    # Sort columns in the following order.
    config.list.sorting = {:login => :asc}

    # Rename the following columns.
    config.columns[:created_at].label = "Created"
    config.columns[:updated_at].label = "Updated"
    config.columns[:activated_at].label = "Activated"
    config.columns[:deleted_at].label = "Deleted"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "User Details"

    # Exclude the following actions.
    config.actions.exclude :create

    # Use field searching.
    config.actions.swap :search, :field_search
  end

  # Restrict who can see what records in list view.
  # - Admins can see everything.
  # - Users in same organization can see only those corresponding records.
  # - Users not in an organization can see only those corresponding records.
  def conditions_for_collection
    return [] if current_user.has_role?(:admin)
    if (!current_user.organization.nil?)
      return [ 'users.organization = ?', current_user.organization.to_s ]
    else
      return [ 'users.organization IS NULL' ]
    end
  end

  # render new.rhtml
  def new
    logout_keeping_session!
    if User.find(:first).nil?
      flash.now[:notice] = "Since this is the first user created, this user will have <b>admin</b> privileges, by default."
    end
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    first_user = User.find(:first).nil?
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    @success = @user && @user.valid?
    if @success && @user.errors.empty?
      # If this account is the first, then make it an admin account.
      if first_user
        @user.roles << Role.find_by_name("admin")
      else
        @user.roles << Role.find_by_name("member")
      end
      flash.now[:notice] = "Account created.  We're sending you an email with your activation code."
      flash.now[:error] = "Please make sure mail from <b>#{ADMIN_EMAIL}</b> is not blocked by your spam filter."
      render :action => :new
    else
      flash[:error]  = "Unable to register account."
      render :action => :new
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = 'Registration complete.  Please <a href="/login">login</a> to continue.'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your activation email."
    else 
      flash[:error]  = 'Invalid activation code or activation already complete. <a href="/login">Login</a> to continue.'
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.
  protected
  def find_user
    @user = User.find(params[:id])
  end

  # Enable signup functionality.
  def create_authorized?
    return true
  end
end
