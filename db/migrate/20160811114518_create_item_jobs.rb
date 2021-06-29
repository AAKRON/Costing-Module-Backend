class CreateItemJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :item_jobs do |t|
      t.decimal :hour_per_piece
      t.belongs_to :item
      t.belongs_to :job_listing
      t.timestamps
    end
  end
end
