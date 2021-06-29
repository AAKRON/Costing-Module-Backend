class BlankJob < ActiveRecord::Migration[5.0]
  def change
    change_column :blank_jobs, :hour_per_piece, :decimal
  end
end
