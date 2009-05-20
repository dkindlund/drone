class ProcessFile < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :os_process #, :counter_cache => :process_file_count
  belongs_to :file_content

  validates_presence_of :name, :event, :time_at
  validates_associated :file_content
  validates_length_of :name, :maximum => 8192
  validates_length_of :event, :maximum => 255
  validates_numericality_of :time_at, :greater_than_or_equal_to => 0

  version 1
  index :event
  index :file_content_id
  index [:file_content_id, :id]
  index :os_process_id
  index [:os_process_id, :id]

  def to_label
    "#{name}"
  end
end
