class AppConstantLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :app_constants_location_prices do |t|
        t.string :value
        t.references :app_constants, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
