require_relative 'boot'

# Ruby 3.1.4 compatibility - load stdlib gems before Rails
require 'logger'
require 'ostruct'
require 'bigdecimal'
require 'mutex_m'
require 'drb'
require 'matrix'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
require 'csv'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CostingModuleApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.active_job.queue_adapter = :sidekiq
    
    # Security middleware
    config.middleware.use Rack::Attack
  end
end
