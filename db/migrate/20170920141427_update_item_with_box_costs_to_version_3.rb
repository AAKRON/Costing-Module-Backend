class UpdateItemWithBoxCostsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    create_view :item_with_box_costs, version: 3
  end
end
