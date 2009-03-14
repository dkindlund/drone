class CreateJobAlerts < ActiveRecord::Migration
  def self.up
    create_table :job_alerts do |t|
      t.string :protocol, :null => false
      t.string :address, :null => false
      t.references :job
    end

    add_index :job_alerts, :job_id
  end

  def self.down
    drop_table :job_alerts
  end
end
