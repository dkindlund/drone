class Url < ActiveRecord::Base

  belongs_to :client
  belongs_to :url_status
  belongs_to :fingerprint
  belongs_to :job, :counter_cache => :url_count

  validates_presence_of :url, :priority, :url_status
  validates_associated :url_status, :fingerprint
  validates_length_of :url, :maximum => 8192
  validates_numericality_of :priority, :greater_than_or_equal_to => 1

end
