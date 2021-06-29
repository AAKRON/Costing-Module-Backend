class CreateItemBoxes < ActiveRecord::Migration[5.0]
  def change
    create_table :item_boxes do |t|
      t.integer :pieces_per_box
      t.belongs_to :box
      t.belongs_to :item
      t.timestamps
    end
  end
end
