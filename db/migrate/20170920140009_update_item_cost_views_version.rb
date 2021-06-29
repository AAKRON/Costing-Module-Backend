class UpdateItemCostViewsVersion < ActiveRecord::Migration[5.0]
  def change
    drop_view :item_cost_views
    create_view :item_cost_views, version: 2
  end
end
