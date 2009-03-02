class CreateFileContents < ActiveRecord::Migration
  def self.up
    create_table :file_contents do |t|
      t.string :md5, :null => false
      t.string :sha1, :null => false
      t.integer :size, :default => 0, :null => false
      t.string :mime_type, :null => false
    end
   
    add_index :file_contents, :md5
    add_index :file_contents, :sha1
    add_index :file_contents, :mime_type
    add_index :file_contents, [:size, :sha1, :md5], :unique => true
  end

  def self.down
    drop_table :file_contents
  end
end
