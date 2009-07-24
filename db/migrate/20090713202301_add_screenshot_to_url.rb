class AddScreenshotToUrl < ActiveRecord::Migration
  def self.up
    add_column :urls, :screenshot_id, :integer
  end

  def self.down
    remove_column :urls, :screenshot_id
  end
end
