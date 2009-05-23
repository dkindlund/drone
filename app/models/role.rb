class Role < ActiveRecord::Base
  include AuthorizationHelper

  has_and_belongs_to_many :users

  version 5
  index :name, :limit => 500, :buffer => 0
end
