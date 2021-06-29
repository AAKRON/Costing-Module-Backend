class AddColumnsToItem < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :box_id, :integer, default: 0
    add_column :items, :number_of_pcs_per_box, :integer, default: 0
    add_column :items, :ink_cost, :decimal, default: 0.0, precision: 4, scale: 4
  end
end
