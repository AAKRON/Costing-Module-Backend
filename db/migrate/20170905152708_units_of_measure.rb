class UnitsOfMeasure < ActiveRecord::Migration[5.0]
  def change
    add_index :units_of_measures, :name, unique: true
  end
end
