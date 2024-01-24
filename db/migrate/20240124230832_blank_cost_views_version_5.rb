class BlankCostViewsV05 < ActiveRecord::Migration[6.1]
  def change
    update_view :blank_cost_views, version: 5, revert_to_version: 4
  end
end
