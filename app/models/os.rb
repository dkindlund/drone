class Os < ActiveRecord::Base
  include AuthorizationHelper

  has_many :clients

  validates_presence_of :name, :version, :short_name
  validates_length_of :name, :maximum => 255
  validates_length_of :version, :maximum => 255
  validates_length_of :short_name, :maximum => 255
  validates_uniqueness_of :short_name, :scope => [:name, :version]

  version 5
  index :name,                          :limit => 500, :buffer => 0
  index :version,                       :limit => 500, :buffer => 0
  index :short_name,                    :limit => 500, :buffer => 0
  index [:name, :version, :short_name], :limit => 500, :buffer => 0

  def to_label
    "#{name} #{version}"
  end
end
