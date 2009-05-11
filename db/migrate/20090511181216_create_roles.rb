require 'active_record/fixtures'

class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table "roles" do |t|
      t.string :name
      t.text   :description
    end
    
    # generate the join table
    create_table "roles_users", :id => false do |t|
      t.integer "role_id", "user_id"
    end

    add_index "roles_users", "role_id"
    add_index "roles_users", "user_id"

    dir = File.join(File.dirname(__FILE__),"initial_data")
    Fixtures.create_fixtures(dir,"roles")

    # Give the default "admin" account the "admin" role.
    User.find(1).roles << Role.find(1)
  end

  def self.down
    drop_table "roles"
    drop_table "roles_users"
  end
end
