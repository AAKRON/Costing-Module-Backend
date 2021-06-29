class ChangeHourPerPcItemJob < ActiveRecord::Migration[5.0]
  def change
    change_column :item_jobs, :hour_per_piece, :float
  end
end
