class CreateColorantCosts < ActiveRecord::Migration[5.0]
  def change
    create_table :colorant_costs do |t|
      t.decimal :colorant_percentage
      t.decimal :cost
      t.belongs_to :blank
      t.belongs_to :colorant
      t.timestamps
    end
  end
end
