class JobAlert < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :job

  validates_presence_of :protocol, :address
  validates_length_of :protocol, :maximum => 255
  validates_length_of :address, :maximum => 255

  version 5
  index :protocol,             :limit => 500, :buffer => 0
  index :address,              :limit => 500, :buffer => 0
  index [:protocol, :address], :limit => 500, :buffer => 0
  index [:job_id, :id],        :limit => 500, :buffer => 0

  def to_label
    "#{protocol}:#{address}"
  end
end
