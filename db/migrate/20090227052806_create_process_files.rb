class CreateProcessFiles < ActiveRecord::Migration
  def self.up
    create_table :process_files do |t|
      t.text :name, :null => false
      t.string :event, :null => false
      t.decimal :time_at, :precision => 30, :scale => 6, :null => false
      t.references :file_content
      t.references :os_process
    end

    add_index :process_files, :file_content_id
    add_index :process_files, :os_process_id
    add_index :process_files, {:name => :name, :length => 1024}
  end

  def self.down
    drop_table :process_files
  end
end
