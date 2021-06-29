class CreateScreenCosts < ActiveRecord::Migration[5.0]
  def change
    create_table :screen_costs do |t|
      t.integer :size
      t.decimal :cost

      t.timestamps
    end
  end
end
