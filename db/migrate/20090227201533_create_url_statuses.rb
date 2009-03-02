require 'active_record/fixtures'

class CreateUrlStatuses < ActiveRecord::Migration
  def self.up
    create_table :url_statuses do |t|
      t.string :status, :null => false
      t.text :description, :null => false
    end

    dir = File.join(File.dirname(__FILE__),"initial_data")
    Fixtures.create_fixtures(dir,"url_statuses")
  end

  def self.down
    drop_table :url_statuses
  end
end
