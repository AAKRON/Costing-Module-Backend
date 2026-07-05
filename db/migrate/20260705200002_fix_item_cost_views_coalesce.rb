class FixItemCostViewsCoalesce < ActiveRecord::Migration[7.2]
  def up
    # no-op: item_cost_views was already rebuilt with COALESCE guards
    # in 20260705200001_update_blank_cost_views_to_version5
  end

  def down; end
end
