class FileContent < ActiveRecord::Base
  include AuthorizationHelper

  has_many :process_files

  validates_presence_of :md5, :sha1, :size, :mime_type
  validates_length_of :md5, :maximum => 255
  validates_length_of :sha1, :maximum => 255
  validates_length_of :mime_type, :maximum => 255
  validates_numericality_of :size, :greater_than_or_equal_to => 0
  validates_uniqueness_of :md5, :scope => [:sha1, :size]

  version 5
  index :md5,                 :limit => 500, :buffer => 0
  index :sha1,                :limit => 500, :buffer => 0
  index :mime_type,           :limit => 500, :buffer => 0
  index [:md5, :sha1],        :limit => 500, :buffer => 0
  index [:md5, :sha1, :size], :limit => 500, :buffer => 0

  def to_label
    "sha1: #{sha1}"
  end
end
