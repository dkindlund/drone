class CreateHosts < ActiveRecord::Migration
  def self.up
    create_table :hosts do |t|
      t.string :hostname, :null => false
      t.string :ip, :null => false

      t.timestamps :null => false
    end

    add_index :hosts, [:ip, :hostname], :unique => true
  end

  def self.down
    drop_table :hosts
  end
end
