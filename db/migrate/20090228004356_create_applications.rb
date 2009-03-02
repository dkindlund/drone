class CreateApplications < ActiveRecord::Migration
  def self.up
    create_table :applications do |t|
      t.string :manufacturer, :null => false
      t.string :version, :null => false
      t.string :short_name, :null => false
    end

    add_index :applications, [:manufacturer, :version, :short_name], :unique => true
  end

  def self.down
    drop_table :applications
  end
end
