class Fingerprint < ActiveRecord::Base

  has_one :url
  has_many :os_processes, :order => 'pid ASC'

  validates_presence_of :checksum, :os_process_count
  validates_associated :os_processes
  validates_length_of :checksum, :maximum => 255
  validates_numericality_of :os_process_count, :greater_than_or_equal_to => 0

end
