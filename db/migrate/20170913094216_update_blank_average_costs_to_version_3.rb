class UpdateBlankAverageCostsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    drop_view :blank_final_calculations_views
    drop_view :blank_cost_views
    update_view :blank_average_costs, version: 3, revert_to_version: 2
    create_view :blank_final_calculations_views, version: 3
    create_view :blank_cost_views, version: 2
  end
end
