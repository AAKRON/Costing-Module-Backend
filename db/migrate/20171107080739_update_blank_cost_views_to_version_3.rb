class UpdateBlankCostViewsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    drop_view :item_cost_views
    drop_view :item_with_blank_per_cost_views
    update_view :blank_cost_views, version: 3, revert_to_version: 2
    create_view :item_with_blank_per_cost_views, version: 1
    create_view :item_cost_views, version: 4
  end
end
