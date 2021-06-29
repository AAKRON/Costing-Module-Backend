class CreateOverheadCosts < ActiveRecord::Migration[5.0]
  def change
    create_table :overhead_costs do |t|
      t.decimal :cost
      t.belongs_to :overhead_percentage
      t.belongs_to :job_listing
      t.timestamps
    end
  end
end
