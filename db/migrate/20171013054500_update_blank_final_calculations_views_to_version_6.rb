class UpdateBlankFinalCalculationsViewsToVersion6 < ActiveRecord::Migration[5.0]
  def change
    update_view :blank_final_calculations_views, version: 6, revert_to_version: 5
  end
end
