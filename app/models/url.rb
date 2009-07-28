require 'stringio'

class Url < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status
  belongs_to :fingerprint
  belongs_to :job, :counter_cache => :url_count
  belongs_to :client
  belongs_to :group
  belongs_to :screenshot

  validates_presence_of :url, :priority, :url_status
  validates_associated :url_status, :fingerprint, :screenshot
  # TODO: Is this the cause for the slowdown?
  #validates_length_of :url, :maximum => 8192
  validates_numericality_of :priority, :greater_than_or_equal_to => 1

  version 17
  index :priority,              :limit => 500, :buffer => 0
  index :url_status_id,         :limit => 500, :buffer => 0
  index [:url_status_id, :id],  :limit => 500, :buffer => 0
  index :fingerprint_id,        :limit => 500, :buffer => 0
  index [:fingerprint_id, :id], :limit => 500, :buffer => 0
  index :job_id,                :limit => 500, :buffer => 0
  index [:job_id, :id],         :limit => 500, :buffer => 0
  index :client_id,             :limit => 500, :buffer => 0
  index [:client_id, :id],      :limit => 500, :buffer => 0
  index :time_at,               :limit => 500, :buffer => 0
  index :group_id,              :limit => 500, :buffer => 0
  index [:group_id, :id],       :limit => 500, :buffer => 0
  index :ip,                    :limit => 500, :buffer => 0
  index :screenshot_id,         :limit => 500, :buffer => 0
  index [:screenshot_id, :id],  :limit => 500, :buffer => 0

  attr_accessor :screenshot_data
  attr_accessor :wait_id
  attr_accessor :end_early_if_load_complete_id
  attr_accessor :reuse_browser_id
  before_validation_on_update :extract_screenshot

  def to_label
    "#{url}"
  end

  def job_source
    if (!self.job.nil? && !self.job.job_source.nil?)
      return self.job.job_source.to_label
    else
      return nil
    end
  end

  # Allow all admins to read any data.
  # Allow members to read only their own data or unowned data.
  def authorized_for_read?
    return true if !existing_record_check?
    if !current_user.nil?
      if current_user.has_role?(:admin)
        return true
      else
        return self.group_id.nil? || !current_user.groups.map{|g| g.is_a?(Group) ? g.id : g}.index(self.group_id).nil?
      end
    else
      return false
    end
  end

  private

  def extract_screenshot()
    if (!self.screenshot_data.nil?)
      # Attempt to save the screenshot.
      self.screenshot = Screenshot.new(:uploaded_data => StringIO.new(self.screenshot_data))
      self.screenshot_data = nil
    end
  end
end
