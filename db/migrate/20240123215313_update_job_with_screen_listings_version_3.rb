class UpdateJobWithScreenListingsVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :job_with_screen_listings, version: 3, revert_to_version: 2
  end
end
