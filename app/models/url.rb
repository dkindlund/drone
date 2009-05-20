class Url < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status
  belongs_to :fingerprint
  belongs_to :job, :counter_cache => :url_count
  belongs_to :client

  validates_presence_of :url, :priority, :url_status
  validates_associated :url_status, :fingerprint
  validates_length_of :url, :maximum => 8192
  validates_numericality_of :priority, :greater_than_or_equal_to => 1

  version 1
  index :priority
  index :url_status_id
  index [:url_status_id, :id]
  index :fingerprint_id
  index [:fingerprint_id, :id]
  index :job_id
  index [:job_id, :id]
  index :client_id
  index [:client_id, :id]
  index :time_at

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
