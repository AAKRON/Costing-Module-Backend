class UpdateBlankFinalCalculationsViewsToVersion8 < ActiveRecord::Migration[7.2]
  def change
    update_view :blank_final_calculations_views, version: 8, revert_to_version: 7
  end
end
