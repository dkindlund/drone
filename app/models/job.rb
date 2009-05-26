class Job < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :client, :counter_cache => :job_count
  belongs_to :job_source
  belongs_to :group
  has_many :job_alerts
  has_many :urls, :before_add => :decrement_src_url_counter_cache, :after_add => :increment_dst_url_counter_cache, :after_remove => :decrement_url_counter_cache

  validates_presence_of :uuid, :job_source
  validates_associated :job_source, :job_alerts, :urls
  validates_length_of :uuid, :maximum => 255
  validates_numericality_of :url_count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :uuid, :scope => [:uuid]

  version 6
  index :uuid,                 :limit => 500, :buffer => 0
  index :completed_at,         :limit => 500, :buffer => 0
  index :created_at,           :limit => 500, :buffer => 0
  index :job_source_id,        :limit => 500, :buffer => 0
  index [:job_source_id, :id], :limit => 500, :buffer => 0
  index :client_id,            :limit => 500, :buffer => 0
  index [:client_id, :id],     :limit => 500, :buffer => 0
  index :group_id,             :limit => 500, :buffer => 0
  index [:group_id, :id],      :limit => 500, :buffer => 0

  before_create :set_group
  after_create [:update_url_counter_cache, :set_urls_group]

  def to_label
    "#{uuid}"
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

  # Allow all admins and members to create new jobs.
  def authorized_for_create?
    return (!current_user.nil? && (current_user.has_role?(:member) || current_user.has_role?(:admin)))
  end

  private

  # Attempts to set the group of a new Job, using the
  # JobSource.group (if specified).
  def set_group
    if (!self.job_source.nil? && !self.job_source.group.nil?)
      self.group = self.job_source.group
    end
  end

  # After self.urls is added, then update each url.group with self.group
  def set_urls_group
    if (!self.id.nil? && !self.group_id.nil?)
      Url.update_all("group_id = " + self.group_id.to_s, [ "job_id = ?", self.id.to_s ])
    end
  end

  # XXX: These methods are probably inefficient, but its not clear how the
  # counter cache can be manipulated in any other way.

  # Before self.urls is added, then make sure the source url.job.url_count
  # gets updated.
  def decrement_src_url_counter_cache(url = nil)
    if (!url.nil? && !url.job.nil?)
      Job.decrement_counter(:url_count, url.job.id)
    end
  end

  # After self.urls is added, then update self.url_count
  def increment_dst_url_counter_cache(url = nil)
    if not self.new_record?
      Job.increment_counter(:url_count, self.id)
    end
  end

  # After self.urls is subtracted, then update self.url_count
  def decrement_url_counter_cache(url = nil)
    if not self.new_record?
      Job.decrement_counter(:url_count, self.id)
    end
  end

  # After self is created, then update self.url_count
  def update_url_counter_cache
    self.url_count.upto(self.urls.size - 1) do
      Job.increment_counter(:url_count, self.id)
    end
  end
end
