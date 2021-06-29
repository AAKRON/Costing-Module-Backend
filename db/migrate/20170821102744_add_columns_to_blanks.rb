class AddColumnsToBlanks < ActiveRecord::Migration[5.0]
  def change
    add_column :blanks, :blank_type, :integer, default: 0
    add_column :blanks, :cost, :decimal, default: 0.0, precision: 8, scale: 3
  end
end
