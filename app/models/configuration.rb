class Configuration < ActiveRecord::Base

  validates_presence_of :name, :value, :namespace
  validates_length_of :name, :maximum => 255
  validates_length_of :value, :maximum => 255
  validates_length_of :namespace, :maximum => 255
  validates_uniqueness_of :name, :scope => [:value, :namespace]

end
