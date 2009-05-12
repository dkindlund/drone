class Job < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :client, :counter_cache => :job_count
  belongs_to :job_source
  has_many :job_alerts
  has_many :urls, :before_add => :decrement_src_url_counter_cache, :after_add => :increment_dst_url_counter_cache, :after_remove => :decrement_url_counter_cache

  validates_presence_of :uuid, :job_source
  validates_associated :job_source, :job_alerts, :urls
  validates_length_of :uuid, :maximum => 255
  validates_numericality_of :url_count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :uuid, :scope => [:uuid]

  after_create :update_url_counter_cache

  def to_label
    "#{uuid}"
  end

  # Allow all admins and members to create new jobs.
  def authorized_for_create?
    return (!current_user.nil? && (current_user.has_role?(:member) || current_user.has_role?(:admin)))
  end

  private

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
