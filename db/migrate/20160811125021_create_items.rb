class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.integer :item_no

      t.timestamps
    end
  end
end
