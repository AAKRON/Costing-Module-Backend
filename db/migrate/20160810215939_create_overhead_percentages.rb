class CreateOverheadPercentages < ActiveRecord::Migration[5.0]
  def change
    create_table :overhead_percentages do |t|
      t.integer :type
      t.integer :percentage

      t.timestamps
    end
  end
end
