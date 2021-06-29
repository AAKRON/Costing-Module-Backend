class AddCellKeyToBlanksListingByItem < ActiveRecord::Migration[5.0]
  def change
    add_column :blanks_listing_by_items, :cell_key, :string
  end
end
