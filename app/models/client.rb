class Client < ActiveRecord::Base

  default_scope :order => 'suspended_at DESC, updated_at DESC'
  named_scope :bad,  :conditions => { :client_status_id => [3,4] }
  # TODO: May need to update this scope.
  named_scope :good, :conditions => { :client_status_id => [1,2] }

  belongs_to :client_status
  belongs_to :host
  belongs_to :os
  belongs_to :application
  has_many   :jobs

  validates_presence_of :quick_clone_name, :snapshot_name, :client_status, :host
  validates_associated :client_status, :host, :os, :application, :jobs
  validates_length_of :quick_clone_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_numericality_of :job_count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :quick_clone_name, :scope => [:snapshot_name]

  def to_label
    "#{id}"
  end
end
