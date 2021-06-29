class ChangeItemInkCostType < ActiveRecord::Migration[5.0]
  def change
    drop_view :item_cost_views
    drop_view :item_with_box_costs
    change_column :items, :ink_cost, :decimal
    create_view :item_cost_views
  end
end
