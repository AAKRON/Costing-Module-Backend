class UpdateFinalCalculationViewsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    replace_view :final_calculation_views, version: 3, revert_to_version: 2
  end
end
