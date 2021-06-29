class CreateBlanksListingItemWithCosts < ActiveRecord::Migration[5.0]
  def change
    create_table :blanks_listing_item_with_costs do |t|
      t.integer :item_number
      t.integer :blank_number
      t.float :cost_per_blank

      t.timestamps
    end
  end
end
