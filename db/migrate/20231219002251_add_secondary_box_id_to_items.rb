class AddSecondaryBoxIdToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :secondary_box_id, :integer, null: true
  end
end
