class Os < ActiveRecord::Base

  has_many :clients

  validates_presence_of :name, :version, :short_name
  validates_length_of :name, :maximum => 255
  validates_length_of :version, :maximum => 255
  validates_length_of :short_name, :maximum => 255
  validates_uniqueness_of :short_name, :scope => [:name, :version]

end
