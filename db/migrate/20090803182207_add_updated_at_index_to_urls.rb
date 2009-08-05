class AddUpdatedAtIndexToUrls < ActiveRecord::Migration
  def self.up
    add_index :urls, :updated_at
  end

  def self.down
    remove_index :urls, :updated_at
  end
end
