class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :uuid, :null => false
      t.integer :url_count, :default => 0, :null => false
      t.datetime :completed_at
      t.references :job_source, :null => false

      t.timestamps :null => false
    end

    add_index :jobs, :uuid
    add_index :jobs, :completed_at
    add_index :jobs, :created_at
    add_index :jobs, :job_source_id
    add_index :jobs, [:uuid], :unique => true, :name => "by_unique_uuid"
  end

  def self.down
    drop_table :jobs
  end
end
