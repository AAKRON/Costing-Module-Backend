class CreateBlankCostViews < ActiveRecord::Migration[5.0]
  def change
    create_view :blank_cost_views
  end
end
