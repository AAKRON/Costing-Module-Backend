class CreateMaterialCosts < ActiveRecord::Migration[5.0]
  def change
    create_table :material_costs do |t|
      t.decimal :ink_cost
      t.decimal :box_cost_per_item
      t.decimal :screen_size_cost
      t.belongs_to :item
      t.timestamps
    end
  end
end
