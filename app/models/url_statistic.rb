class UrlStatistic < ActiveRecord::Base

  belongs_to :url_status

  validates_presence_of :count, :url_status
  validates_numericality_of :count, :greater_than_or_equal_to => 0
  validates_uniqueness_of :url_status_id, :scope => [:created_at, :updated_at]

end
