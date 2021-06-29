class CreateUnitsOfMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :units_of_measures do |t|
      t.string :name
      t.string :abbr

      t.timestamps
    end
  end
end
