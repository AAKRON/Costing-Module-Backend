class UpdateItemCostViewVersion8 < ActiveRecord::Migration[6.1]
  def change
    update_view :item_cost_views, version: 8, revert_to_version: 7
  end
end
