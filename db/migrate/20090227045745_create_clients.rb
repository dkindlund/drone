class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :quick_clone_name,  :null => false
      t.string :snapshot_name,     :null => false
      t.datetime :suspended_at
      t.references :host,          :null => false
      t.references :client_status, :null => false
      t.references :os
      t.references :application

      t.timestamps :null => false
    end

    add_index :clients, :host_id
    add_index :clients, :client_status_id
    add_index :clients, :os_id
    add_index :clients, :application_id
    add_index :clients, :created_at
    add_index :clients, :updated_at
    add_index :clients, :suspended_at
    add_index :clients, [:quick_clone_name, :snapshot_name], :unique => true
  end

  def self.down
    drop_table :clients
  end
end
