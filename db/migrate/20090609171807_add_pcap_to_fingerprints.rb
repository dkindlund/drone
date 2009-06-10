class AddPcapToFingerprints < ActiveRecord::Migration
  def self.up
    add_column :fingerprints, :pcap, :string, :default => nil, :null => true
    add_index :fingerprints, :pcap
  end

  def self.down
    remove_index :fingerprints, :pcap
    remove_column :fingerprints, :pcap
  end
end
