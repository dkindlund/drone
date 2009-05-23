class Url < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status
  belongs_to :fingerprint
  belongs_to :job, :counter_cache => :url_count
  belongs_to :client

  validates_presence_of :url, :priority, :url_status
  validates_associated :url_status, :fingerprint
  # TODO: Is this the cause for the slowdown?
  #validates_length_of :url, :maximum => 8192
  validates_numericality_of :priority, :greater_than_or_equal_to => 1

  version 14
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
end
