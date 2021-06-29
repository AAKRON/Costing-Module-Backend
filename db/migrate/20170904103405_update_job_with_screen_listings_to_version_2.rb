class UpdateJobWithScreenListingsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    update_view :job_with_screen_listings, version: 2, revert_to_version: 1
  end
end
