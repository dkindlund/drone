class CreateProcessRegistries < ActiveRecord::Migration
  def self.up
    create_table :process_registries do |t|
      t.text :name, :null => false
      t.string :event, :null => false
      t.text :value_name
      t.string :value_type
      t.binary :value
      t.decimal :time_at, :precision => 30, :scale => 6, :null => false
      t.references :os_process
    end

    add_index :process_registries, :os_process_id
    add_index :process_registries, {:name => :name, :length => 1024}
  end

  def self.down
    drop_table :process_registries
  end
end
