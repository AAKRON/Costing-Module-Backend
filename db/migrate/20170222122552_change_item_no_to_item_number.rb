class ChangeItemNoToItemNumber < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :item_no, :item_number

    add_index :items, :item_number, unique: true
  end
end
