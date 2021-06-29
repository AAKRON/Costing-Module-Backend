class CreateFinalCalculationViews < ActiveRecord::Migration[5.0]
  def change
    create_view :final_calculation_views
  end
end
