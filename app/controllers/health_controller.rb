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
      user_count: (User.count rescue 'error'),
      available_routes: [
        '/health',
        '/setup/schema_load', 
        '/setup/migrate',
        '/setup/seed'
      ]
    }
  end
  
  # Emergency user creation endpoint
  def create_user
    return render json: { error: 'Not allowed in production' }, status: 403 if Rails.env.production?
    
    begin
      user = User.create!(
        username: 'testuser', 
        password: 'TestPass123', 
        password_confirmation: 'TestPass123', 
        role: 'admin'
      )
      
      render json: {
        status: 'success',
        message: 'Test user created successfully',
        user: { username: user.username, role: user.role },
        login: { username: 'testuser', password: 'TestPass123' }
      }
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end
end