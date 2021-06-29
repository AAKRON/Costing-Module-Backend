class RenameCostPerUnitOnBox < ActiveRecord::Migration[5.0]
  def change
    rename_column :boxes, :cost_per_unit, :cost_per_box
  end
end
