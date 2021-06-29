Raven.configure do |config|
  config.dsn = 'https://142f80cc46f6427e99b94baa72e1382c:841e6917e53045a484249c5977ec1e92@sentry.io/162055'
  config.environments = ['staging', 'production']
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end

