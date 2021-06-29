class CreateRawMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :raw_materials do |t|
      t.string :name
      t.decimal :cost_per_unit
      t.string :unit_of_measure

      t.timestamps
    end
  end
end
