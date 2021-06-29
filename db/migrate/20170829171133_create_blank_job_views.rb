class CreateBlankJobViews < ActiveRecord::Migration[5.0]
  def change
    create_view :blank_job_views
  end
end
