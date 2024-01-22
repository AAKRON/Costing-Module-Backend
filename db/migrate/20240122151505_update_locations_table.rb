class UpdateLocationsTable < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :active_flag, :integer, default: 1, limit: 1
  end
end
