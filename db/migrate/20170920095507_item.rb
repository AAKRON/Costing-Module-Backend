class Item < ActiveRecord::Migration[5.0]
  def change
      add_column :items, :item_type_id, :integer, default: 0
  end
end
