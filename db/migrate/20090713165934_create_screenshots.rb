class CreateScreenshots < ActiveRecord::Migration
  def self.up
    create_table :screenshots do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
    end
  end

  def self.down
    drop_table :screenshots
  end
end
