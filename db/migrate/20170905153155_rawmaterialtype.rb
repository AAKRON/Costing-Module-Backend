class Rawmaterialtype < ActiveRecord::Migration[5.0]
  def change
    add_index :rawmaterialtypes, :name, unique: true
  end
end
