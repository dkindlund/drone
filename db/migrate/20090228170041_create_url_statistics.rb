class CreateUrlStatistics < ActiveRecord::Migration
  def self.up
    create_table :url_statistics do |t|
      t.integer :count
      t.references :url_status

      t.timestamps
    end

    add_index :url_statistics, :created_at
    add_index :url_statistics, :updated_at
    add_index :url_statistics, :url_status_id
    add_index :url_statistics, :count
  end

  def self.down
    drop_table :url_statistics
  end
end
