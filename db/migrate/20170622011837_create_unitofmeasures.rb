class CreateUnitofmeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :unitofmeasures do |t|
      t.string :name
      t.string :abbr

      t.timestamps
    end
  end
end
