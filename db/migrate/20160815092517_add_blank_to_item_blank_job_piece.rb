class AddBlankToItemBlankJobPiece < ActiveRecord::Migration[5.0]
  def change
    add_column :item_blank_job_pieces, :blank_id, :integer
    add_column :item_blank_job_pieces, :item_job_id, :integer
  end
end
