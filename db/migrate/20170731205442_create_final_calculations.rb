class CreateFinalCalculations < ActiveRecord::Migration[5.0]
  def change
    create_table :final_calculations do |t|
      t.integer :manufactured_blank_id
      t.integer :color_number
      t.string  :color_description
      t.integer :raw_material_id

      t.string  :colorant_one
      t.integer :number_of_pieces_per_unit_one
      t.float   :percentage_of_colorant_one

      t.string  :colorant_two
      t.integer :number_of_pieces_per_unit_two
      t.float   :percentage_of_colorant_two

      t.timestamps
    end
  end
end
