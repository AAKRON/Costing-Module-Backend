class UpdateBlankAverageCostsToVersion5 < ActiveRecord::Migration[5.0]
  def change
    drop_view :item_cost_views
    drop_view :item_with_blank_per_cost_views
    drop_view :blank_cost_views
    drop_view :blank_final_calculations_views
    update_view :blank_average_costs, version: 5, revert_to_version: 4
    create_view :blank_cost_views
    create_view :blank_final_calculations_views
  end
end
