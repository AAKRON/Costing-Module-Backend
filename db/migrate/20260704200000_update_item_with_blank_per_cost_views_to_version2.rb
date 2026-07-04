class UpdateItemWithBlankPerCostViewsToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :item_with_blank_per_cost_views, version: 2, revert_to_version: 1
  end
end
