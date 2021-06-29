class CreateBlankTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :blank_types do |t|
      t.integer :type_number, unique: true, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :blank_types, :type_number
  end
end
