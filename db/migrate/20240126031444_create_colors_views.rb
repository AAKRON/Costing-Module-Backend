class CreateColorsViews < ActiveRecord::Migration[6.1]
  def change
    create_view :colors_views
  end
end