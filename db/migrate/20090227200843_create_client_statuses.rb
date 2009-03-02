require 'active_record/fixtures'

class CreateClientStatuses < ActiveRecord::Migration
  def self.up
    create_table :client_statuses do |t|
      t.string :status, :null => false
      t.text :description, :null => false
    end

    add_index :client_statuses, [:status], :unique => true

    dir = File.join(File.dirname(__FILE__),"initial_data")
    Fixtures.create_fixtures(dir,"client_statuses")
  end

  def self.down
    drop_table :client_statuses
  end
end
