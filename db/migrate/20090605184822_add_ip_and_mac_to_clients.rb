class AddIpAndMacToClients < ActiveRecord::Migration
  def self.up
    add_column :clients, :ip, :string, :default => nil, :null => true
    add_column :clients, :mac, :string, :default => nil, :null => true
  end

  def self.down
    remove_column :clients, :mac
    remove_column :clients, :ip
  end
end
