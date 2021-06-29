class AddColumnsToJobListingAndItem < ActiveRecord::Migration[5.0]
  def change
    add_column :job_listings, :job_number, :integer, unique: true, index: true
    add_column :items, :description, :string
  end
end
