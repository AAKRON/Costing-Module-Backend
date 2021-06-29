class CreateItemCostViews < ActiveRecord::Migration[5.0]
  def change
    create_view :item_cost_views
  end
end
