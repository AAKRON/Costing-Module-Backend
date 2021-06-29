class ChangeWagesPerHourOnJobListing < ActiveRecord::Migration[5.0]
  def change
    change_column :job_listings, :wages_per_hour, :float
  end
end
