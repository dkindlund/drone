class OsProcess < ActiveRecord::Base

  belongs_to :fingerprint, :counter_cache => :os_process_count
  has_many :process_files
  has_many :process_registries

  validates_presence_of :name, :pid
  validates_associated :process_files, :process_registries
  validates_length_of :name, :maximum => 8192 
  validates_length_of :parent_name, :allow_nil => true, :allow_blank => true, :maximum => 8192
  validates_numericality_of :pid, :greater_than_or_equal_to => 0
  validates_numericality_of :parent_pid, :allow_nil => true, :allow_blank => true, :greater_than_or_equal_to => 0
  validates_numericality_of :process_file_count, :greater_than_or_equal_to => 0
  validates_numericality_of :process_registry_count, :greater_than_or_equal_to => 0

  def to_label
    "#{name}"
  end
end
