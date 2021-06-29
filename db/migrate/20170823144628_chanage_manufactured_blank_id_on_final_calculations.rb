class ChanageManufacturedBlankIdOnFinalCalculations < ActiveRecord::Migration[5.0]
  def change
    rename_column :final_calculations, :manufactured_blank_id, :blank_id

    add_index :final_calculations, :blank_id
  end
end
