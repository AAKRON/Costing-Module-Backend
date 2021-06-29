class AddRawMaterialTypeToRawMaterial < ActiveRecord::Migration[5.0]
  def change
    add_column :raw_materials, :rawmaterialtype_id, :integer
  end
end
