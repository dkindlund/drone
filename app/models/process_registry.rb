class ProcessRegistry < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :os_process #, :counter_cache => :process_registry_count

  validates_presence_of :name, :event, :time_at
  validates_length_of :name, :maximum => 8192
  validates_length_of :event, :maximum => 255
  validates_length_of :value_name, :allow_nil => true, :allow_blank => true, :maximum => 8192
  validates_length_of :value_type, :allow_nil => true, :allow_blank => true, :maximum => 255
  validates_numericality_of :time_at, :greater_than_or_equal_to => 0

  version 5
  index :event,                :limit => 500, :buffer => 0
  index :value_type,           :limit => 500, :buffer => 0
  index :os_process_id,        :limit => 500, :buffer => 0
  index [:os_process_id, :id], :limit => 500, :buffer => 0

  def to_label
    "#{name}"
  end
end
