class AltertableScreencostsAndRenameColumnSizeAndChangeColumnCost < ActiveRecord::Migration[5.0]
  def change
    rename_column :screen_costs, :size, :screen_size
    change_column :screen_costs, :cost, :float
  end
end
