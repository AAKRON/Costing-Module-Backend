class UpdateBlankFinalCalculationsViewsToVersion7 < ActiveRecord::Migration[5.0]
  def change
    update_view :blank_final_calculations_views, version: 7, revert_to_version: 6
  end
end
