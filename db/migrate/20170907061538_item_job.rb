class ItemJob < ActiveRecord::Migration[5.0]
  def change
    change_column :item_jobs, :hour_per_piece, :decimal
  end
end
