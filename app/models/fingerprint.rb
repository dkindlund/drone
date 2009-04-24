require 'md5'

class Fingerprint < ActiveRecord::Base

  has_one :url
  has_many :os_processes, :order => 'pid ASC', :before_add => :decrement_src_os_process_counter_cache, :after_add => :increment_dst_os_process_counter_cache, :after_remove => :decrement_os_process_counter_cache

  validates_presence_of :os_process_count
  validates_associated :os_processes
  validates_length_of :checksum, :allow_nil => true, :maximum => 255
  validates_numericality_of :os_process_count, :greater_than_or_equal_to => 0

  before_create :calculate_checksum
  after_create :update_os_process_counter_cache

  def to_label
    "#{checksum}"
  end

  private

  # Calculates the fingerprint checksum, if need be.
  def calculate_checksum()
    # Don't calculate, if a checksum was already provided.
    if not self.checksum.nil?
        return
    end

    # Create an array of process strings, sort, and md5
    process_strings = []
    self.os_processes.each do |p|

      # Begin string with process name.
      process_string = p.name.to_s

      # Append sorted files.
      file_strings = []
      p.process_files.each do |f|
        if (f.event == "Delete" ||
            f.file_content.nil? ||
            f.file_content.md5  == "UNKNOWN" ||
            f.file_content.sha1 == "UNKNOWN")
          file_string = f.name.to_s
        else
          file_string = f.file_content.md5.to_s + f.file_content.sha1.to_s
        end
        file_string += f.event.to_s
        file_strings << file_string
      end
      process_string += file_strings.sort.join("")

      # Append sorted registries.
      registry_strings = []
      p.process_registries.each do |rk|
        registry_string = rk.name.to_s
        registry_string += rk.event.to_s
        registry_string += rk.value_name.to_s
        # XXX: Does not currently include value name or value type.
        registry_strings << registry_string
      end
      process_string += registry_strings.sort.join("")
      process_strings << process_string
    end

    # Calculate the corresponding checksum.
    self.checksum = Digest::MD5.hexdigest(process_strings.sort.join(""))
  end

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
    end
  end

  # After self.os_processes is subtracted, then update self.os_process_count
  def decrement_os_process_counter_cache(os_process = nil)
    if not self.new_record?
      Fingerprint.decrement_counter(:os_process_count, self.id)
    end
  end

  # After self is created, then update self.os_process_count
  def update_os_process_counter_cache
    self.os_process_count.upto(self.os_processes.size - 1) do
      Fingerprint.increment_counter(:os_process_count, self.id)
    end
  end
end
