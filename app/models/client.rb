class Client < ActiveRecord::Base

  belongs_to :client_status
  belongs_to :host
  belongs_to :os
  belongs_to :application
  has_many   :urls

  validates_presence_of :quick_clone_name, :snapshot_name, :client_status, :host
  validates_associated :client_status, :host, :os, :application, :urls
  validates_length_of :quick_clone_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_length_of :snapshot_name, :maximum => 255
  validates_uniqueness_of :quick_clone_name, :scope => [:snapshot_name]

end
