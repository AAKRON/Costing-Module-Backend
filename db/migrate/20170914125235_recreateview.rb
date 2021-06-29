class Recreateview < ActiveRecord::Migration[5.0]
  def change
    drop_view :blank_cost_views
    create_view :blank_cost_views, version: 2
    drop_view :blank_final_calculations_views
    create_view :blank_final_calculations_views, version: 4
    create_view :item_with_blank_per_cost_views, version: 1
    create_view :item_cost_views, version: 1
  end
end
