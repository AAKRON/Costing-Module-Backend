class CreateRawmaterialtypes < ActiveRecord::Migration[5.0]
  def change
    create_table :rawmaterialtypes do |t|
      t.string :name

      t.timestamps
    end
  end
end
