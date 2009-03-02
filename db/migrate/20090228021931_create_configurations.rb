class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :name, :null => false
      t.string :value, :null => false
      t.string :namespace, :null => false
      t.text :description
      t.string :default_value
    end

    add_index :configurations, :name
    add_index :configurations, :namespace
    add_index :configurations, [:value, :name, :namespace], :unique => true
  end

  def self.down
    drop_table :configurations
  end
end