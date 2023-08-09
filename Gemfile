source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.7.7'
gem 'rails', '~> 6.1.1'
# gem 'rails', '~> 5.0.0'
gem 'pg'
# gem 'puma', '~> 3.0'
gem 'puma'
# gem 'jbuilder', '~> 2.5'
gem 'bcrypt'
gem 'jbuilder'
gem 'kaminari'
gem 'newrelic_rpm'
gem 'pdfkit'
gem 'pry-rails'
gem 'rack-cors', require: 'rack/cors'
gem 'redis'
gem 'rubyXL'
gem 'scenic'
gem 'sentry-raven'
gem 'sidekiq'
gem 'upsert'
gem 'wkhtmltopdf-heroku'
gem 'smarter_csv'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'roo'


group :development, :test do
  gem 'byebug', platform: :mri
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'guard-rspec'
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'seed_dump'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'railroady'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'codeclimate-test-reporter'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'shoulda-context'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
