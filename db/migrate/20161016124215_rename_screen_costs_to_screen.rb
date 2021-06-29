class RenameScreenCostsToScreen < ActiveRecord::Migration[5.0]
  def change
    rename_table :screen_costs, :screens
  end
end
