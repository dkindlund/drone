class Application < ActiveRecord::Base

  validates_presence_of :manufacturer, :version, :short_name
  validates_length_of :manufacturer, :maximum => 255
  validates_length_of :version, :maximum => 255
  validates_length_of :short_name, :maximum => 255
  validates_uniqueness_of :short_name, :scope => [:manufacturer, :version]

end
