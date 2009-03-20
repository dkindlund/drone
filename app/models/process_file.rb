class ProcessFile < ActiveRecord::Base

  belongs_to :os_process #, :counter_cache => :process_file_count
  belongs_to :file_content

  validates_presence_of :name, :event, :time_at
  validates_associated :file_content
  validates_length_of :name, :maximum => 8192
  validates_length_of :event, :maximum => 255
  validates_numericality_of :time_at, :greater_than_or_equal_to => 0

  def to_label
    "#{name}"
  end
end
