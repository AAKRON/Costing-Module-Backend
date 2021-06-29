class CreateItemWithBlankPerCostViews < ActiveRecord::Migration[5.0]
  def change
    create_view :item_with_blank_per_cost_views
  end
end
