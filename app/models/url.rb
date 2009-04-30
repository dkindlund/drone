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

  def to_label
    "#{url}"
  end

end
