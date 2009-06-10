class Url < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status
  belongs_to :fingerprint
  belongs_to :job, :counter_cache => :url_count
  belongs_to :client
  belongs_to :group

  validates_presence_of :url, :priority, :url_status
  validates_associated :url_status, :fingerprint
  # TODO: Is this the cause for the slowdown?
  #validates_length_of :url, :maximum => 8192
  validates_numericality_of :priority, :greater_than_or_equal_to => 1

  version 16
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
end
