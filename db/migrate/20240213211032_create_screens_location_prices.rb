class CreateScreensLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :screens_location_prices do |t|
        t.decimal :cost
        t.references :screens, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
