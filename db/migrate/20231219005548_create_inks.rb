class CreateInks < ActiveRecord::Migration[6.1]
  def change
    create_table :inks do |t|
      t.string :name
      t.decimal :ink_cost

      t.timestamps
    end
  end
end
