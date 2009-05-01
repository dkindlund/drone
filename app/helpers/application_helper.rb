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
      time_ago_in_words(record.suspended_at) + " ago"
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
      time_ago_in_words(Time.at(record.time_at.to_f)) + " ago"
    end
  end
end
