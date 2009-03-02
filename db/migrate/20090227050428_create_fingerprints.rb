class CreateFingerprints < ActiveRecord::Migration
  def self.up
    create_table :fingerprints do |t|
      t.integer :os_process_count, :default => 0, :null => false
      t.string :checksum, :null => false
    end

    add_index :fingerprints, :checksum
  end

  def self.down
    drop_table :fingerprints
  end
end
