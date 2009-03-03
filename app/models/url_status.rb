class UrlStatus < ActiveRecord::Base

  has_many :urls
  has_many :url_statistics

  validates_presence_of :status, :description
  validates_length_of :status, :maximum => 255
  validates_length_of :description, :maximum => 8192
  validates_uniqueness_of :status, :scope => [:status]

  def to_label
    "#{status}"
  end
end
