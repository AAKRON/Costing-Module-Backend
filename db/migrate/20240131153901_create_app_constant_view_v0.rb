class CreateAppConstantViewV0 < ActiveRecord::Migration[6.1]
  def change
    create_view :app_constants_views
  end
end
