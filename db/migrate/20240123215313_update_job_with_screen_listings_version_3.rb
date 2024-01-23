class UpdateJobWithScreenListingsVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :item_cost_views, version: 3, revert_to_version: 2
  end
end
