class CreateInksLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :inks_location_prices do |t|
        t.decimal :ink_cost
        t.references :inks, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
