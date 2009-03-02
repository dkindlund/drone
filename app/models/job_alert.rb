class JobAlert < ActiveRecord::Base

  belongs_to :job

  validates_presence_of :protocol, :address
  validates_length_of :protocol, :maximum => 255
  validates_length_of :address, :maximum => 255

end
