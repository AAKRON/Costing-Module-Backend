class CreateBlankRawMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :blank_raw_materials do |t|
      t.integer :piece_per_unit_of_measure
      t.decimal :cost
      t.belongs_to :blank
      t.belongs_to :raw_material
      t.timestamps
    end
  end
end
