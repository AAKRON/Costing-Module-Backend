# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: '1.0.0',
      rails_version: Rails.version,
      available_routes: [
        '/health',
        '/setup/schema_load', 
        '/setup/migrate',
        '/setup/seed'
      ]
    }
  end
end