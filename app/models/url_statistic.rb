class UrlStatistic < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :url_status

  validates_presence_of :count, :url_status
  validates_numericality_of :count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :url_status_id, :scope => [:created_at, :updated_at]

  version 5
  index :created_at,                                :limit => 500, :buffer => 0
  index :updated_at,                                :limit => 500, :buffer => 0
  index :url_status_id,                             :limit => 500, :buffer => 0
  index [:url_status_id, :id],                      :limit => 500, :buffer => 0
  index :count,                                     :limit => 500, :buffer => 0
  index [:created_at, :updated_at, :url_status_id], :limit => 500, :buffer => 0

  def to_label
    "#{created_at} (#{count})"
  end
end
