class UpdateItemCostView < ActiveRecord::Migration[6.1]
  def change
    update_view :item_cost_views, version: 7, revert_to_version: 6
  end
end
