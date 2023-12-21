class AddNumberOfPeacesSecondaryBoxToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :number_of_pcs_per_secondary_box, :integer, default: 0, null: true
  end
end
