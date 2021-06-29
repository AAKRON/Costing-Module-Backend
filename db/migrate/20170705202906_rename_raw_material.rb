class RenameRawMaterial < ActiveRecord::Migration[5.0]
  def change
    change_column :raw_materials, :cost_per_unit, :float
    rename_column :raw_materials, :cost_per_unit, :cost

    change_column :raw_materials, :unit_of_measure, 'integer USING CAST(unit_of_measure AS integer)'
    rename_column :raw_materials, :unit_of_measure, :units_of_measure_id

    add_column :raw_materials, :color_id, :integer
    add_column :raw_materials, :vendor_id, :integer
  end
end
