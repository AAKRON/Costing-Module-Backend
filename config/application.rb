require_relative 'boot'

# stdlib compatibility — still needed in Ruby 3.3 for some gems
require 'logger'
require 'ostruct'
require 'bigdecimal'
require 'mutex_m'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
require 'csv'

Bundler.require(*Rails.groups)

module CostingModuleApi
  class Application < Rails::Application
    config.load_defaults 7.2

    config.api_only = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.active_job.queue_adapter = :sidekiq
    config.middleware.use Rack::Attack
  end
end
