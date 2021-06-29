class CreateBlanks < ActiveRecord::Migration[5.0]
  def change
    create_table :blanks do |t|
      t.string :description
      t.integer :number
      t.integer :type
      t.decimal :cost
      t.belongs_to :item
      t.timestamps
    end
  end
end
