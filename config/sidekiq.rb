Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: :resque }
  config.reliable_fetch!

  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=250"
    ActiveRecord::Base.establish_connection
  end

  $elastic = Elasticsearch::Client.new
  Stretchy.client = $elastic
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], namespace: :resque }
end

Sidekiq::Client.reliable_push! unless Rails.env.test?
