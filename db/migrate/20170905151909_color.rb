class Color < ActiveRecord::Migration[5.0]
  def change
    add_index :colors, :name, unique: true
  end
end
