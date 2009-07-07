class JobAlertsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :admin_required, :only => [:index, :list]

  active_scaffold :job_alert do |config|
    # Table Title
    config.list.label = "Job Notifiers"

    # Show the following columns in the specified order.
    config.list.columns = [:job, :address, :protocol]
    config.show.columns = [:job, :address, :protocol]

    # Rename the following columns.
    config.columns[:job].label = "Job ID"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Notification Details"

    # Include the following show actions.
    config.columns[:job].set_link :show, :controller => 'jobs', :parameters => {:parent_controller => 'job_alerts'}

    # Use field searching.
    config.actions.swap :search, :field_search

    # Add export options.
    config.actions.add :export
    config.export.columns = [:job, :address, :protocol]
    config.export.force_quotes = true
    config.export.allow_full_download = true

    # Support ATOM Format
    config.formats << :atom
  end

  protected
  def list_respond_to_atom
    @job_alerts = JobAlert.find(:all, :order => 'job_alerts.id DESC', :limit => Configuration.find_retry(:name => "atom.max_entries", :namespace => "JobAlert").to_i)

    respond_to do |format|
      format.atom
    end
  end

  def admin_required
    if (current_user.nil? || !current_user.has_role?(:admin))
      redirect_back_or_default('/')
    end
  end
end
