class RenameManufacturedBlankJobsToBlankJobs < ActiveRecord::Migration[5.0]
  def change
    rename_table :manufactured_blank_jobs, :blank_jobs
    rename_column :blank_jobs, :manufactured_blank_id, :blank_id
  end
end
