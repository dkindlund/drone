module ClientsHelper

  # Show the created_at time in words.
  def created_at_column(record)
    if not record.created_at.nil?
      time_ago_in_words(record.created_at) + " ago"
    end
  end

  # Show the suspended_at time in words.
  def suspended_at_column(record)
    if not record.suspended_at.nil?
      time_ago_in_words(record.suspended_at) + " ago"
    end
  end

  # Show the updated_at time in words.
  def updated_at_column(record)
    if not record.updated_at.nil?
      time_ago_in_words(record.updated_at) + " ago"
    end
  end
end
