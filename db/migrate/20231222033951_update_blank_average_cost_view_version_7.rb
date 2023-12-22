class UpdateBlankAverageCostViewVersion7 < ActiveRecord::Migration[6.1]
  def change
    drop_view :item_cost_views
    drop_view :item_with_blank_per_cost_views
    drop_view :blank_cost_views
    drop_view :blank_final_calculations_views
    update_view :blank_average_costs, version: 7, revert_to_version: 6
    create_view :blank_final_calculations_views, version: 7
    create_view :blank_cost_views, version: 4
    create_view :item_with_blank_per_cost_views, version: 2
    create_view :item_cost_views, version: 6
  end
end
