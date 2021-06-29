class CreateItemTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :item_types do |t|
      t.integer :type_number, unique: true, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :item_types, :type_number
  end
end
