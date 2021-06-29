class BlankDescription < ActiveRecord::Migration[5.0]
  def change
    drop_view :blank_final_calculations_views
    drop_view :item_cost_views
    drop_view :item_with_blank_per_cost_views
    drop_view :blank_cost_views
    drop_view :blank_views
    drop_view :blank_job_views
    change_column :blanks, :description, :string, null: true
    create_view :blank_final_calculations_views, version: 5
    create_view :blank_cost_views, version: 2
    create_view :item_with_blank_per_cost_views, version: 1
    create_view :item_cost_views, version: 3
    create_view :blank_views, version: 2
    create_view :blank_job_views, version: 1
  end
end
