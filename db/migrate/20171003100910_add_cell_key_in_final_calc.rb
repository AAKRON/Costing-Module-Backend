class AddCellKeyInFinalCalc < ActiveRecord::Migration[5.0]
  def change
    add_column :final_calculations, :cell_key, :string, unique: true
  end
end
