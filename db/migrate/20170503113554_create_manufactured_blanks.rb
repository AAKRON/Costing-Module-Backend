class CreateManufacturedBlanks < ActiveRecord::Migration[5.0]
  def change
    create_table :manufactured_blanks do |t|
      t.string :description, null: false
      t.integer :blank_number, null: false, unique: true

      t.timestamps
    end
  end
end
