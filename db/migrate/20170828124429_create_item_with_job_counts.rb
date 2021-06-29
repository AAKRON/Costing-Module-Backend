class CreateItemWithJobCounts < ActiveRecord::Migration[5.0]
  def change
    create_view :item_with_job_counts
  end
end
