class ChanageBlankTypeOnBlank < ActiveRecord::Migration[5.0]
  def change
    rename_column :blanks, :blank_type, :blank_type_id
  end
end
