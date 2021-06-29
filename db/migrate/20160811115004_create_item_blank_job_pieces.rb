class CreateItemBlankJobPieces < ActiveRecord::Migration[5.0]
  def change
    create_table :item_blank_job_pieces do |t|
      t.decimal :hour_per_piece

      t.timestamps
    end
  end
end
