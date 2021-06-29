class CreateBlanksListingByItems < ActiveRecord::Migration[5.0]
  def change
    create_table :blanks_listing_by_items do |t|
      t.integer :item_number
      t.integer :blank_number
      t.integer :mult
      t.integer :div

      t.timestamps
    end
  end
end
