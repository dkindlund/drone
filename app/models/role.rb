class Role < ActiveRecord::Base
  include AuthorizationHelper

  has_and_belongs_to_many :users

  version 1
  index :name
end
