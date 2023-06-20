source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.7.7'
gem 'rails', '~> 6.1.1'
#gem 'rails', '~> 5.0.0'
gem 'pg'
#gem 'puma', '~> 3.0'
gem 'puma'
#gem 'jbuilder', '~> 2.5'
gem 'jbuilder'
gem 'rack-cors', :require => 'rack/cors'
gem 'bcrypt'
gem 'rubyXL'
gem 'upsert'
gem 'sidekiq'
gem 'kaminari'
gem 'pry-rails'
gem 'redis'
gem "sentry-raven"
gem 'scenic'
gem 'newrelic_rpm'
gem 'wkhtmltopdf-heroku'
gem 'pdfkit'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry-nav'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'faker'
  gem 'seed_dump'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'railroady'
end


group :test do
  gem 'shoulda-matchers', '~> 3.1'
  gem "codeclimate-test-reporter"
  gem 'simplecov', :require => false
  gem 'coveralls', require: false
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem 'shoulda'
  gem 'shoulda-context'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
