# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    current_db = ActiveRecord::Base.connection.current_database rescue 'unknown'
    
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: '1.0.0',
      rails_version: Rails.version,
      current_database: current_db,
      database_url: ENV['DATABASE_URL'].present? ? 'configured' : 'not set',
      postgres_url: ENV['POSTGRES_URL'].present? ? 'configured' : 'not set',
      available_routes: [
        '/health',
        '/setup/schema_load', 
        '/setup/migrate',
        '/setup/seed'
      ]
    }
  end
end