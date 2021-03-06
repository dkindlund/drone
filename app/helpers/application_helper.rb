# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Show the created_at time in words.
  def created_at_column(record)
    if not record.created_at.nil?
      time_ago_in_words(record.created_at) + " ago"
    end
  end

  # Show the completed_at time in words.
  def completed_at_column(record)
    if not record.completed_at.nil?
      time_ago_in_words(record.completed_at) + " ago"
    end
  end

  # Show the suspended_at time in words.
  def suspended_at_column(record)
    if not record.suspended_at.nil?
      # TODO: Delete this?
      # TODO: time_ago_in_words(record.suspended_at) + " ago"
      record.suspended_at.strftime("%b %d %H:%M:%S %Z %Y")
    end
  end

  # Show the updated_at time in words.
  def updated_at_column(record)
    if not record.updated_at.nil?
      time_ago_in_words(record.updated_at) + " ago"
    end
  end

  # Show the time_at time in words.
  def time_at_column(record)
    if not record.time_at.nil?
      if record.is_a?(Client)
        time_ago_in_words(Time.at(record.time_at.to_f)) + " ago"
      else
        time = Time.at(record.time_at.to_f)
        return time.strftime("%b %d %H:%M:%S.") + record.time_at.frac.to_s.sub!('0.','') + time.strftime(" %Z %Y")
      end
    end
  end

  # Truncate the value column if greater than the specified length.
  def value_column(record)
    if (record.value.to_s.length > 47)
      h(record.value.to_s[0,47]) + "..."
    else
      h(record.value.to_s)
    end
  end
  
  # Truncate the default_value column if greater than the specified length.
  def default_value_column(record)
    if (record.value.to_s.length > 47)
      h(record.value.to_s[0,47]) + "..."
    else
      h(record.value.to_s)
    end
  end

  # Make sure the description column is completely printed.
  def description_column(record)
    if not record.description.nil?
      h(record.description)
    end
  end

  # Provide a downloadable link to the file data, if available
  # for the file_content column.
  def file_content_column(record)
    value = "-"
    if !record.file_content.nil? && record.file_content.mime_type != "UNKNOWN"
      value = "sha1: " + record.file_content.sha1.to_s
      if !record.file_content.data.nil?
        value = link_to(h("sha1: " + record.file_content.sha1.to_s), { :controller => "file_contents", :action => "download_data", :id => record.file_content.id }, :confirm => "WARNING: This file potentially contains malware.\nNOTE: When extracting, use the password: '" + Configuration.find_retry(:name => "file_content.zip.password", :namespace => "FileContent").to_s + "'\nProceed with download?")
      end
    end
    return value
  end

  # Render a small thumbnail of the screenshot in the column.
  def screenshot_column(record)
    if (!record.screenshot.nil?)
      return link_to(image_tag(url_for({ :controller => "urls",
                                         :action     => "screenshot_small",
                                         :id         => record.id }),
                                       :alt => "Screenshot (Small)"),
                     { :controller => "urls",
                       :action     => "screenshot_large",
                       :id         => record.id },
                     :popup        => true)
    else
      return "-"
    end
  end

  # Assign a CSS class, for the following record types.
  def list_row_class(record)
    if record.is_a?(Client)
      record.client_status.status
    elsif record.is_a?(Url)
      record.url_status.status
    end
  end

  # Defines a copy to clipboard flash widget, used for
  # copying arbitrary text.
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end

  # When editing Clients, make sure the client status field is properly refreshed.
  def client_status_form_column(record, input_name)
    record.expire_caches
    record.reload
    collection_select(:record, :client_status, ClientStatus.find(:all, :order => "status ASC"), :id, :status, {:selected => record.client_status_id}, {:status => input_name}) 
  end
end
