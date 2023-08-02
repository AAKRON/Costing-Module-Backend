require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :raw_materials
      resources :rawmaterialtypes
      resources :vendors
      resources :units_of_measures
      resources :colors
      resources :items
      resources :blanks
      resources :sessions, only: :create
      resources :screens
      resources :job_listings
      resources :item_jobs
      resources :blank_jobs
      post '/items-and-blanks-listings', to: 'files#items_and_blanks_listings'
      resources :final_calculations
      resources :blanks_listing_item_with_costs
      resources :blanks_listing_by_items
      resources :blank_types
      resources :boxes
      resources :users
      resources :item_types
      resources :app_constants
      post '/items/:id/update-type', to: 'items#update_type'
      get '/item-list-only', to: 'items#item_list_only'
      get '/job-list-only', to: 'job_listings#job_list_only'
      get '/jobs-by-params', to: 'job_listings#jobs_by_params'
      put '/update-item-jobs-only/:id', to: 'item_jobs#update_item_jobs_only'
      put '/update-item-job-data', to: 'item_jobs#update_item_jobs_data'
      get '/blank-list-only', to: 'blanks#blank_list_only'
      get '/vendors-list-only', to: 'vendors#vendor_list_only'
      put '/update-blank-jobs-only/:id', to: 'blank_jobs#update_blank_jobs_only'
      put '/update-blank-job-data', to: 'blank_jobs#update_blank_jobs_data'
      get 'download/:file_type', to: 'files#download'
      get '/box-list-only', to: 'boxes#box_list_only'
      get '/item-type-list-only', to: 'item_types#item_type_list_only'
      get '/units-of-measure-list-only', to: 'units_of_measures#units_of_measure_list_only'
      get '/color-list-only', to: 'colors#color_list_only'
      get '/vendor-list-only', to: 'vendors#vendor_list_only'
      get '/raw-material-type-list-only', to: 'rawmaterialtypes#raw_material_type_list_only'
      get '/raw-material-list-only', to: 'raw_materials#raw_material_list_only'
      get '/item-download/:cost_type', to: 'files#item_download'
      get '/blank-download/:cost_type', to: 'files#blank_download'
      get '/raw-material-download/:cost_type', to: 'files#raw_material_download'
      get '/color-download/:cost_type', to: 'files#color_download'
      get '/units-download/:cost_type', to: 'files#units_download'      
      get '/raw-material-type-download/:cost_type', to: 'files#raw_material_type_download'
      get '/vendors-download/:cost_type', to: 'files#vendors_download'
      put '/job-cost-calculate/:id', to: 'job_listings#job_cost_calculate'
      post '/cost-pdf-download', to: 'files#cost_pdf_download'
      put '/update-item-blanks-only/:item_id', to: 'blanks_listing_by_items#update_item_blanks_only'
      put '/update-item-blanks-data', to: 'blanks_listing_by_items#update_item_blanks_data'
      put '/update-item-blanks-with-cost-only/:item_id', to: 'blanks_listing_item_with_costs#update_item_blanks_with_cost_only'

      ###### BOXES ########
      get '/box-list-for-costing-module-download/:cost_type', to: 'files#box_download'
      post'/box_list_for_costing_module', to: 'files#update_or_create_boxes'

      ##### 
    end
  end
end
