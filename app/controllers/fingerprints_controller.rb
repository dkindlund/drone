class FingerprintsController < ApplicationController
  active_scaffold :fingerprint do |config|
    # Show the following columns in the specified order.
    config.list.columns = [:checksum, :os_process_count]

    # Rename the following columns.
    config.columns[:os_process_count].label = "# Processes Found"
  end
end
