class UpdateItemCostViewsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    update_view :item_cost_views, version: 3, revert_to_version: 2
  end
end
