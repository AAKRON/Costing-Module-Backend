class DropTableBlanks < ActiveRecord::Migration[5.0]
  def change
    drop_table :blanks
  end
end
