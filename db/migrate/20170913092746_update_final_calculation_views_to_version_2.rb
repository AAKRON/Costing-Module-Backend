class UpdateFinalCalculationViewsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    replace_view :final_calculation_views, version: 2, revert_to_version: 1
  end
end
