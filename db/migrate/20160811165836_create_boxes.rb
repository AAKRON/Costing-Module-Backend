class CreateBoxes < ActiveRecord::Migration[5.0]
  def change
    create_table :boxes do |t|
      t.string :name
      t.decimal :cost_per_unit

      t.timestamps
    end
  end
end
