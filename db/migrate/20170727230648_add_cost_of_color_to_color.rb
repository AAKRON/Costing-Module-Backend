class AddCostOfColorToColor < ActiveRecord::Migration[5.0]
  def change
    add_column :colors, :cost_of_color, :float
  end
end
