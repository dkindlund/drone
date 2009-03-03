class JobSource < ActiveRecord::Base

  has_many :jobs

  validates_presence_of :name, :protocol
  validates_length_of :name, :maximum => 255
  validates_length_of :protocol, :maximum => 255
  validates_uniqueness_of :name, :scope => [:protocol]

  def to_label
    "#{name}"
  end
end
