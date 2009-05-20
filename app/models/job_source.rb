class JobSource < ActiveRecord::Base
  include AuthorizationHelper

  has_many :jobs

  validates_presence_of :name, :protocol
  validates_length_of :name, :maximum => 255
  validates_length_of :protocol, :maximum => 255
  validates_uniqueness_of :name, :scope => [:protocol]

  version 1
  index :name
  index :protocol
  index [:name, :protocol]

  def to_label
    "#{name}"
  end
end
