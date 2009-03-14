class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.decimal    :time_at,     :precision => 30, :scale => 6
      t.text       :url,         :limit => 8192,   :null => false
      t.integer    :priority,    :default => 1,    :null => false

      # XXX: If no status is given, we assume a value of (1=queued).
      t.references :url_status,  :default => 1,    :null => false
      t.references :fingerprint
      t.references :job

      t.timestamps :null => false
    end

    add_index :urls, :time_at
    add_index :urls, :created_at
    add_index :urls, :fingerprint_id
    add_index :urls, :url_status_id
    add_index :urls, :job_id
    add_index :urls, :priority
    add_index :urls, {:name => :url, :length => 1024}
  end

  def self.down
    drop_table :urls
  end
end
