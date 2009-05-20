class ClientStatus < ActiveRecord::Base
  include AuthorizationHelper

  has_many :clients

  validates_presence_of :status, :description
  validates_length_of :status, :maximum => 255
  validates_length_of :description, :maximum => 255
  validates_uniqueness_of :status, :scope => [:status]

  version 1
  index :status

  def to_label
    "#{status}"
  end
end
