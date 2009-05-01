class FileContentsController < ApplicationController
  active_scaffold :file_content do |config|
    # Table Title
    config.list.label = "File Contents"

    # Show the following columns in the specified order.
    config.list.columns = [:mime_type, :size, :md5, :sha1]

    # Sort columns in the following order.
    config.list.sorting = {:sha1 => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:process_files].includes = nil

    # Rename the following columns.
    config.columns[:md5].label = "MD5"
    config.columns[:sha1].label = "SHA1"
    config.columns[:mime_type].label = "Type"
    config.columns[:size].label = "Size (Bytes)"
  end
end
