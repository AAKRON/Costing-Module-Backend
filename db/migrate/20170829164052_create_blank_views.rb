class CreateBlankViews < ActiveRecord::Migration[5.0]
  def change
    create_view :blank_views
  end
end
