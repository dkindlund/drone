class CreateJobSources < ActiveRecord::Migration
  def self.up
    create_table :job_sources do |t|
      t.string :name, :null => false
      t.string :protocol, :null => false
    end

    add_index :job_sources, :name
    add_index :job_sources, :protocol
    add_index :job_sources, [:name, :protocol], :unique => true, :name => "by_unique_name_and_protocol"
  end

  def self.down
    drop_table :job_sources
  end
end
