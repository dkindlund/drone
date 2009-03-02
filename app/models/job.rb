class Job < ActiveRecord::Base

  belongs_to :job_source
  has_many :job_alerts
  has_many :urls 

  validates_presence_of :uuid
  validates_associated :job_source, :job_alerts, :urls
  validates_length_of :uuid, :maximum => 255
  validates_numericality_of :url_count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :uuid, :scope => [:uuid]

end
