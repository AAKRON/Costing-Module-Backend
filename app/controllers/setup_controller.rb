# frozen_string_literal: true
class SetupController < ApplicationController
  # No authentication required for setup endpoints
  
  def schema_load
    begin
      # Load schema from schema.rb (faster and more reliable than migrations)
      load(Rails.root.join('db/schema.rb'))
      
      render json: { 
        status: 'success', 
        message: 'Database schema loaded successfully from schema.rb',
        timestamp: Time.current 
      }
    rescue => e
      render json: { 
        status: 'error', 
        message: e.message,
        timestamp: Time.current 
      }, status: 500
    end
  end
  
  def migrate
    begin
      # Run database migrations
      ActiveRecord::Migration.verbose = true
      ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate')).migrate
      
      render json: { 
        status: 'success', 
        message: 'Database migrations completed successfully',
        timestamp: Time.current 
      }
    rescue => e
      render json: { 
        status: 'error', 
        message: e.message,
        timestamp: Time.current 
      }, status: 500
    end
  end
  
  def seed
    begin
      # Run database seeds
      Rails.application.load_seed
      
      render json: { 
        status: 'success', 
        message: 'Database seeding completed successfully',
        timestamp: Time.current 
      }
    rescue => e
      render json: { 
        status: 'error', 
        message: e.message,
        timestamp: Time.current 
      }, status: 500
    end
  end
end