class UpdateItemWithBlankPerCostViewsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    drop_view :item_cost_views
    update_view :item_with_blank_per_cost_views, version: 2, revert_to_version: 1
    create_view :item_cost_views, version: 6
  end
end
