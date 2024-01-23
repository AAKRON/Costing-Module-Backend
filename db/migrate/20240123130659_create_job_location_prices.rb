class CreateJobLocationPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :job_location_prices do |t|
        t.decimal :wages_per_hour
        t.references :job_listings, null: true, foreign_key: true
        t.references :locations, null: true, foreign_key: true

        t.timestamps
    end
  end
end
