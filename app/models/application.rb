class Application < ActiveRecord::Base
  include AuthorizationHelper

  validates_presence_of :manufacturer, :version, :short_name
  validates_length_of :manufacturer, :maximum => 255
  validates_length_of :version, :maximum => 255
  validates_length_of :short_name, :maximum => 255
  validates_uniqueness_of :short_name, :scope => [:manufacturer, :version]

  version 1
  index :manufacturer
  index :version
  index :short_name
  index [:manufacturer, :version, :short_name]

  def to_label
    abbreviation = short_name.split(" ").map {|word| word[0].chr}.join
    "#{abbreviation} #{version}"
  end
end
