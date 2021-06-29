class CreateJobListings < ActiveRecord::Migration[5.0]
  def change
    create_table :job_listings do |t|
      t.string :description
      t.decimal :wages_per_hour
      t.belongs_to :screen_cost
      t.timestamps
    end
  end
end
