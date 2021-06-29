class CreateBlankFinalCalculationsViews < ActiveRecord::Migration[5.0]
  def change
    create_view :blank_final_calculations_views
  end
end
