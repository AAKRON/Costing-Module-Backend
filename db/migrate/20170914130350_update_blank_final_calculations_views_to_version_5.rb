class UpdateBlankFinalCalculationsViewsToVersion5 < ActiveRecord::Migration[5.0]
  def change
    update_view :blank_final_calculations_views, version: 5, revert_to_version: 4
  end
end
