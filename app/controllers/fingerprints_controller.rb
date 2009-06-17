class FingerprintsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column, :show_export, :export if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :check_for_nested_urls

  active_scaffold :fingerprint do |config|
    # Table Title
    config.list.label = "Fingerprints"

    # Show the following columns in the specified order.
    config.list.columns = [:checksum, :os_process_count]

    # Sort columns in the following order.
    config.list.sorting = {:checksum => :asc}

    # Rename the following columns.
    config.columns[:os_process_count].label = "# Processes Found"
    config.columns[:pcap].label = "Packet Capture"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Fingerprint Details"

    # Add export options.
    config.actions.add :export
    config.export.columns = [:checksum, :os_process_count]
    config.export.force_quotes = true
    config.export.allow_full_download = true
  end

  # Helper function to determine if the fingerprint view should show
  # nested URLs.
  def check_for_nested_urls
    if params[:parent_controller] == "urls"
      @show_nested_urls = false
    else
      @show_nested_urls = true
    end
  end
end
