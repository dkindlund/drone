class Group < ActiveRecord::Base
  include AuthorizationHelper

  has_and_belongs_to_many :users
  has_many :job_sources
  has_many :jobs
  has_many :urls

  validates_length_of  :name, :within => 2..100
  validates_associated :job_sources, :jobs, :urls

  version 6
  # TODO: Disabled, since new group registration was causing
  # problems with Group.find_or_create_by_name()
  #index :name, :limit => 500, :buffer => 0
end
