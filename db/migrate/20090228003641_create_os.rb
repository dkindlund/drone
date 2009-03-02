class CreateOs < ActiveRecord::Migration
  def self.up
    create_table :os do |t|
      t.string :name, :null => false
      t.string :version, :null => false
      t.string :short_name, :null => false
    end

    add_index :os, [:name, :version, :short_name], :unique => true
  end

  def self.down
    drop_table :os
  end
end
