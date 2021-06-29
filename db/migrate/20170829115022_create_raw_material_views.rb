class CreateRawMaterialViews < ActiveRecord::Migration[5.0]
  def change
    create_view :raw_material_views
  end
end
