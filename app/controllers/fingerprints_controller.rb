class FingerprintsController < ApplicationController
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

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "Fingerprint Details"
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
