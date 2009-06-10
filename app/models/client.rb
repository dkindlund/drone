class Client < ActiveRecord::Base
  include AuthorizationHelper

  named_scope :bad,  :conditions => { :client_status_id => [3,4] }
  # TODO: May need to update this scope.
  named_scope :good, :conditions => { :client_status_id => [1,2] }

  belongs_to :client_status
  belongs_to :host
  belongs_to :os
  belongs_to :application
  has_many   :jobs
  has_many   :urls, :through => :jobs

  validates_presence_of :quick_clone_name, :snapshot_name, :client_status, :host
  validates_associated :client_status, :host, :os, :application, :jobs
  validates_length_of :quick_clone_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_numericality_of :job_count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :quick_clone_name, :scope => [:snapshot_name]

  version 5
  index :host_id,                            :limit => 500, :buffer => 0
  index [:host_id, :id],                     :limit => 500, :buffer => 0
  index :client_status_id,                   :limit => 500, :buffer => 0
  index [:client_status_id, :id],            :limit => 500, :buffer => 0
  index :os_id,                              :limit => 500, :buffer => 0
  index [:os_id, :id],                       :limit => 500, :buffer => 0
  index :application_id,                     :limit => 500, :buffer => 0
  index [:application_id, :id],              :limit => 500, :buffer => 0
  index :created_at,                         :limit => 500, :buffer => 0
  index :updated_at,                         :limit => 500, :buffer => 0
  index :suspended_at,                       :limit => 500, :buffer => 0
  index [:quick_clone_name, :snapshot_name], :limit => 500, :buffer => 0

  def to_label
    "#{id}"
  end

  # Allow all admins to update any data.
  # TODO: Allow "editors" to update only their own client_status data.
  def authorized_for_update?
    return (!current_user.nil? && current_user.has_role?(:admin))
  end
end
