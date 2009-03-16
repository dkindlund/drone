class CreateOsProcesses < ActiveRecord::Migration
  def self.up
    create_table :os_processes do |t|
      t.text :name, :null => false
      t.integer :pid, :null => false
      t.text :parent_name
      t.integer :parent_pid
      t.integer :process_file_count, :default => 0, :null => false
      t.integer :process_registry_count, :default => 0, :null => false
      t.references :fingerprint
    end

    add_index :os_processes, :fingerprint_id
    add_index :os_processes, {:name => :name, :length => 1024}
    add_index :os_processes, {:name => :parent_name, :length => 1024}
  end

  def self.down
    drop_table :os_processes
  end
end
