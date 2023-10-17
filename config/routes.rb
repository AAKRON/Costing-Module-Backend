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
      get '/charts', to: 'charts#get_charts_info'
      put '/job-cost-calculate/:id', to: 'job_listings#job_cost_calculate'
      post '/cost-pdf-download', to: 'files#cost_pdf_download'
      put '/update-item-blanks-only/:item_id', to: 'blanks_listing_by_items#update_item_blanks_only'
      put '/update-item-blanks-data/:item_id', to: 'blanks_listing_by_items#update_item_blanks_data'
      put '/update-item-blanks-with-cost-only/:item_id', to: 'blanks_listing_item_with_costs#update_item_blanks_with_cost_only'

      ###### JOB LISTING ########
      get '/jobs_and_blanks_download/:document_type', to: 'files#job_listing_download'
      post '/job_listing_dashboard' ,to: 'files#update_or_create_jobs'
      ##### RAW MATERIAL #######
      get '/raw_materials_download/:document_type', to: 'files#raw_materials'
      post '/raw_materials_dashboard', to: 'files#update_or_create_raw_materials'
      ###### BLANK LISTING WITH COST ########
      get '/blanks_listing_item_with_cost_download/:document_type', to: 'files#blanks_listing_item_with_cost_download'
      post '/blanks_listing_item_with_cost_dashboard', to: 'files#update_or_create_blanks_listing_item_with_cost'
      ###### BLANK ITEMS BY ITEM ########
      get '/blanks_listing_by_item_download/:document_type', to: 'files#blanks_listing_by_item_download'
      post '/blanks_listing_by_item_dashboard', to: 'files#update_or_create_blanks_listing_by_item'
      ###### BOXES ########
      get '/box_list_for_costing_module_download/:document_type', to: 'files#box_download'
      post '/box_list_for_costing_module', to: 'files#update_or_create_boxes'      
      ###### ITEM LISTING FOR COSTING ########
      get '/item_list_for_costing_module_download/:document_type', to: 'files#item_list_for_costing_module_download'
      post '/item_list_for_costing_module_dashboard', to: 'files#update_or_create_item_list_for_costing_module'    
      ###### SCREEN CLICHE SIZES ########
      get '/screen_cliche_sizes_for_costing_module_download/:document_type', to: 'files#screen_cliche_sizes_for_costing_module_download'
      post '/screen_cliche_sizes_for_costing_module_dashboard', to: 'files#update_or_create_screen_cliche_sizes_for_costing_module'  
      ###### BLANKS REPORT ########
      get '/blanks_report_download/:document_type', to: 'files#blanks_report_download'
      post '/blanks_report_dashboard', to: 'files#update_or_create_blanks_report'      
      ###### ITEM LISTING WITH ITEM TYPES ########
      get '/item_listing_with_item_types_download/:document_type', to: 'files#item_listing_with_item_types_download'
      post '/item_listing_with_item_types_dashboard', to: 'files#update_or_create_item_listing_with_item_types'      
    end
  end
end
