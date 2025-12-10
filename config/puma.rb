min_threads = Integer(ENV['PUMA_MIN_THREADS'] || 0)
max_threads = Integer(ENV['PUMA_MAX_THREADS'] || 3)

threads     min_threads, max_threads
# Railway sets PORT automatically, fallback to 3000
port_num = ENV.fetch('PORT', 3000).to_i
port port_num
environment ENV['RACK_ENV']
activate_control_app
state_path 'tmp/puma.state'

if ENV['PUMA_WORKERS'].to_i > 1
  workers ENV['PUMA_WORKERS']
  preload_app!

  on_worker_boot do
    # Valid on Rails 4.1+ using the `config/database.yml` method of setting `pool` size
    # https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute('set statement_timeout to 10000')
  end
end

on_restart do
  Sidekiq.redis.shutdown { |conn| conn.close }
end
