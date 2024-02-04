class CreateRawMaterialsLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :raw_materials_location_prices do |t|
        t.decimal :cost
        t.references :raw_materials, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
