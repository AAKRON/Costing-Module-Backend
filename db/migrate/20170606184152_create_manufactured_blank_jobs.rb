class CreateManufacturedBlankJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :manufactured_blank_jobs do |t|
      t.float :hour_per_piece
      t.integer :manufactured_blank_id
      t.integer :job_listing_id

      t.timestamps
    end
  end
end
