class FingerprintsController < ApplicationController
  active_scaffold :fingerprint do |config|
    # Table Title
    config.list.label = "Fingerprints"

    # Show the following columns in the specified order.
    config.list.columns = [:checksum, :os_process_count]

    # Sort columns in the following order.
    config.list.sorting = {:checksum => :asc}

    # Rename the following columns.
    config.columns[:os_process_count].label = "# Processes Found"
  end
end
