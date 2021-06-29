class CreateScreenSizes < ActiveRecord::Migration[5.0]
  def change
    create_table :screen_sizes do |t|
      t.string :size
      t.decimal :cost

      t.timestamps
    end
  end
end
