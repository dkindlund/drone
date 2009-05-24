class FileContentsController < ApplicationController
  ssl_required :render_field, :new, :create, :delete, :destroy, :search, :show_search, :index, :table, :update_table, :row, :list, :nested, :show, :edit_associated, :edit, :update, :update_column if (Rails.env.production? || Rails.env.development?)
  before_filter :login_required
  before_filter :check_for_nested_process_files

  active_scaffold :file_content do |config|
    # Table Title
    config.list.label = "File Contents"

    # Show the following columns in the specified order.
    config.list.columns = [:mime_type, :size, :md5, :sha1]
    config.show.columns = [:mime_type, :size, :md5, :sha1]

    # Sort columns in the following order.
    config.list.sorting = {:sha1 => :asc}

    # Disable eager loading for the following attributes.
    config.columns[:process_files].includes = nil

    # Rename the following columns.
    config.columns[:md5].label = "MD5"
    config.columns[:sha1].label = "SHA1"
    config.columns[:mime_type].label = "Type"
    config.columns[:size].label = "Size (Bytes)"
    config.columns[:process_files].label = "Process Files"

    # Rename the following actions.
    config.show.link.label = "Details"
    config.show.label = "File Details"
  end

  # Helper function to determine if the file_contents view should show
  # nested process_files.
  def check_for_nested_process_files
    if params[:parent_controller] == "process_files"
      @show_nested_process_files = false
    else
      @show_nested_process_files = true
    end
  end
end
