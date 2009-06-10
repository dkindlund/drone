class AddIpToUrls < ActiveRecord::Migration
  def self.up
    add_column :urls, :ip, :string, :default => nil, :null => true
    add_index :urls, :ip
  end

  def self.down
    remove_index :urls, :ip
    remove_column :urls, :ip
  end
end
