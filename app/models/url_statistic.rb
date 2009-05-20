class UrlStatistic < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status

  validates_presence_of :count, :url_status
  validates_numericality_of :count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :url_status_id, :scope => [:created_at, :updated_at]

  version 1
  index :created_at
  index :updated_at
  index :url_status_id
  index [:url_status_id, :id]
  index :count
  index [:created_at, :updated_at, :url_status_id]

  def to_label
    "#{created_at} (#{count})"
  end
end
