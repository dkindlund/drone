class AddDataToFileContents < ActiveRecord::Migration
  def self.up
    add_column :file_contents, :data, :string, :default => nil, :null => true
    add_index :file_contents, :data
  end

  def self.down
    remove_index :file_contents, :data
    remove_column :file_contents, :data
  end
end
