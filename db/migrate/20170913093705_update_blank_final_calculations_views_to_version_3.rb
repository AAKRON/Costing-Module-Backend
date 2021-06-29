class UpdateBlankFinalCalculationsViewsToVersion3 < ActiveRecord::Migration[5.0]
  def change
    replace_view :blank_final_calculations_views, version: 3, revert_to_version: 2
  end
end
