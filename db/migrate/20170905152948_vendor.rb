class Vendor < ActiveRecord::Migration[5.0]
  def change
    add_index :vendors, :name, unique: true
  end
end
