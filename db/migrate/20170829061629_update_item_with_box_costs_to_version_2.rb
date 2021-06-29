class UpdateItemWithBoxCostsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    update_view :item_with_box_costs, version: 2, revert_to_version: 1
  end
end
