# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

 Rails.application.config.middleware.insert_before 0, Rack::Cors do
   allow do
     # Railway UAT deployment URLs
     origins 'https://costing-module-frontend-uat-production.up.railway.app',
             'https://costing-module-frontend-uat-production-3820.up.railway.app',
             'https://web-production-bf5b5.up.railway.app', 
             'https://uat.aakronline.com',
             'http://localhost:3000', 
             'https://staging.aakronline.com'

     resource '*',
       headers: :any,
       expose: ['X-Total-Count', 'Access-Control-Expose-Headers'],
       methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
 end
