class Application < ActiveRecord::Base
  include AuthorizationHelper

  validates_presence_of :manufacturer, :version, :short_name
  validates_length_of :manufacturer, :maximum => 255
  validates_length_of :version, :maximum => 255
  validates_length_of :short_name, :maximum => 255
  validates_uniqueness_of :short_name, :scope => [:manufacturer, :version]

  version 5
  index :manufacturer,                          :limit => 500, :buffer => 0
  index :version,                               :limit => 500, :buffer => 0
  index :short_name,                            :limit => 500, :buffer => 0
  index [:manufacturer, :version, :short_name], :limit => 500, :buffer => 0

  def to_label
    abbreviation = short_name.split(" ").map {|word| word[0].chr}.join
    "#{abbreviation} #{version}"
  end
end
