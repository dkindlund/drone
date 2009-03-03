class FileContent < ActiveRecord::Base

  has_many :process_files

  validates_presence_of :md5, :sha1, :size, :mime_type
  validates_length_of :md5, :maximum => 255
  validates_length_of :sha1, :maximum => 255
  validates_length_of :mime_type, :maximum => 255
  validates_numericality_of :size, :greater_than_or_equal_to => 0
  validates_uniqueness_of :md5, :scope => [:sha1, :size]

  def to_label
    "sha1: #{sha1}"
  end
end
