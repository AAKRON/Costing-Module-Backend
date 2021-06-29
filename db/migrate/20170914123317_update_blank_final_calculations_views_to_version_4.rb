class UpdateBlankFinalCalculationsViewsToVersion4 < ActiveRecord::Migration[5.0]
  def change
    update_view :blank_final_calculations_views, version: 4, revert_to_version: 3
  end
end
