class CreateBoxesLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :boxes_location_prices do |t|
        t.decimal :cost_per_box
        t.references :boxes, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
