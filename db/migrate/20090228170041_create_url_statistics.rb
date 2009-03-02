class CreateUrlStatistics < ActiveRecord::Migration
  def self.up
    create_table :url_statistics do |t|
      t.integer :count, :null => false, :default => 0
      t.references :url_status, :null => false

      t.timestamps :null => false
    end

    add_index :url_statistics, :created_at
    add_index :url_statistics, :updated_at
    add_index :url_statistics, :url_status_id
    add_index :url_statistics, :count
    add_index :url_statistics, [:created_at, :updated_at, :url_status_id], :unique => true, :name => "by_unique_range"
  end

  def self.down
    drop_table :url_statistics
  end
end
