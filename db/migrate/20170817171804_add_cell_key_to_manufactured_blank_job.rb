class AddCellKeyToManufacturedBlankJob < ActiveRecord::Migration[5.0]
  def change
    add_column :manufactured_blank_jobs, :cell_key, :string
  end
end
