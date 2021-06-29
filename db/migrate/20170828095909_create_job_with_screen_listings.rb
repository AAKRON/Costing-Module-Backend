class CreateJobWithScreenListings < ActiveRecord::Migration[5.0]
  def change
    create_view :job_with_screen_listings
  end
end
