class AddCellKeyToItemJob < ActiveRecord::Migration[5.0]
  def change
    add_column :item_jobs, :cell_key, :string
  end
end
