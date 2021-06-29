class AddCellKeyToBlanksListingItemWithCost < ActiveRecord::Migration[5.0]
  def change
    add_column :blanks_listing_item_with_costs, :cell_key, :string
  end
end
