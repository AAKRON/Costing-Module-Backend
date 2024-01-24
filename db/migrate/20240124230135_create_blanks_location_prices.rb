class CreateBlanksLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :blanks_location_prices do |t|
        t.decimal :cost
        t.references :blanks, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
