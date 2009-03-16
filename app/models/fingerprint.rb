class Fingerprint < ActiveRecord::Base

  has_one :url
  has_many :os_processes, :order => 'pid ASC', :before_add => :decrement_src_os_process_counter_cache, :after_add => :increment_dst_os_process_counter_cache, :after_remove => :decrement_os_process_counter_cache

  validates_presence_of :checksum, :os_process_count
  validates_associated :os_processes
  validates_length_of :checksum, :maximum => 255
  validates_numericality_of :os_process_count, :greater_than_or_equal_to => 0

  after_create :update_os_process_counter_cache

  def to_label
    "#{checksum}"
  end

  private

  # XXX: These methods are probably inefficient, but its not clear how the
  # counter cache can be manipulated in any other way.

  # Before self.os_processes is added, then make sure the source os_process.fingerprint.os_process_count
  # gets updated.
  def decrement_src_os_process_counter_cache(os_process = nil)
    if (!os_process.nil? && !os_process.fingerprint.nil?)
      Fingerprint.decrement_counter(:os_process_count, os_process.fingerprint.id)
    end
  end

  # After self.os_processes is added, then update self.os_process_count
  def increment_dst_os_process_counter_cache(os_process = nil)
    if not self.new_record?
      Fingerprint.increment_counter(:os_process_count, self.id)
      self.reload
    end
  end

  # After self.os_processes is subtracted, then update self.os_process_count
  def decrement_os_process_counter_cache(os_process = nil)
    if not self.new_record?
      Fingerprint.decrement_counter(:os_process_count, self.id)
      self.reload
    end
  end

  # After self is created, then update self.os_process_count
  def update_os_process_counter_cache
    self.os_process_count.upto(self.os_processes.size - 1) do
      Fingerprint.increment_counter(:os_process_count, self.id)
    end
    self.reload
  end
end
