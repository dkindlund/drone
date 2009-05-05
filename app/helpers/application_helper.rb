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
      record.value.to_s[0,47] + "..."
    else
      record.value.to_s
    end
  end

  # Make sure the description column is completely printed.
  def description_column(record)
    if not record.description.nil?
      h(record.description)
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
end
