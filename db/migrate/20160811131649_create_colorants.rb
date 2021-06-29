class CreateColorants < ActiveRecord::Migration[5.0]
  def change
    create_table :colorants do |t|
      t.string :description
      t.string :cost

      t.timestamps
    end
  end
end
