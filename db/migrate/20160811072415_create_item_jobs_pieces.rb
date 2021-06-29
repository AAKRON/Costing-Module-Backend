class CreateItemJobsPieces < ActiveRecord::Migration[5.0]
  def change
    create_table :item_jobs_pieces do |t|
      t.decimal :hour_per_piece
      t.belongs_to :blank
      t.belongs_to :item_job
      t.timestamps
    end
  end
end
