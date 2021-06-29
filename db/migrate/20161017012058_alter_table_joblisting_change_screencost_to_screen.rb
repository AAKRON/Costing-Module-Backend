class AlterTableJoblistingChangeScreencostToScreen < ActiveRecord::Migration[5.0]
  def change
    rename_column :job_listings, :screen_cost_id, :screen_id
  end
end
