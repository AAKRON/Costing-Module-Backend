# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Build origins list: env var takes precedence, known staging domains always allowed
    origins_list = [
      ENV['FRONTEND_URL'],           # set in Railway dashboard to the frontend service URL
      'http://localhost:3000',
      'http://localhost:3001',
      'https://uat.aakronline.com',
      'https://staging.aakronline.com',
    ].compact.uniq

    origins(*origins_list)

    resource '*',
      headers: :any,
      expose: ['X-Total-Count', 'Access-Control-Expose-Headers'],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
