class Host < ActiveRecord::Base
  include AuthorizationHelper

  has_many :clients

  validates_presence_of :hostname, :ip
  validates_length_of :hostname, :maximum => 255
  # TODO: Need proper IP address validation, or save as inet_ton format in future.
  validates_length_of :ip, :maximum => 255
  validates_uniqueness_of :hostname, :scope => [:ip]

  version 1
  index :hostname
  index :ip
  index [:hostname, :ip]

  def to_label
    "#{hostname}"
  end
end
