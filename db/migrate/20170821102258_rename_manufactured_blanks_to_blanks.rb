class RenameManufacturedBlanksToBlanks < ActiveRecord::Migration[5.0]
  def change
    rename_table :manufactured_blanks, :blanks
  end
end
