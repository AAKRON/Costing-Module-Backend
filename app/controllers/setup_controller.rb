# frozen_string_literal: true
class SetupController < ApplicationController
  # No authentication required for setup endpoints
  before_action :set_current_database
  
  private
  
  def set_current_database
    connection_config = Rails.application.config.database_configuration[Rails.env]
    database = ENV['PG_DB_DEV']

    if request.headers['Database'] && request.headers['Database'] != 'null' && request.headers['Database'] != Time.now.year.to_s
        database ='costing_module_db_' + request.headers['Database']
    end

    if ActiveRecord::Base.connection.current_database != database
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
    end

    Rails.logger.debug "Selected database #{database}"
  end
  
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
      # Run database migrations (Rails 6.1+ syntax)
      ActiveRecord::Migration.verbose = true
      
      # Rails 6.1+ requires schema_migration connection as second parameter
      migration_context = ActiveRecord::MigrationContext.new(
        Rails.root.join('db/migrate'), 
        ActiveRecord::SchemaMigration
      )
      migration_context.migrate
      
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
  
  def create_test_user
    begin
      # Create a test user for UAT login
      user = User.find_or_initialize_by(email: 'test@aakronline.com')
      user.assign_attributes(
        password: 'TestPassword123!',
        password_confirmation: 'TestPassword123!',
        name: 'UAT Test User'
      )
      
      if user.save
        render json: {
          status: 'success',
          message: 'Test user created successfully',
          user: {
            email: user.email,
            name: user.name,
            id: user.id
          },
          login_credentials: {
            email: 'test@aakronline.com',
            password: 'TestPassword123!'
          },
          timestamp: Time.current
        }
      else
        render json: {
          status: 'error',
          message: 'Failed to create user',
          errors: user.errors.full_messages,
          timestamp: Time.current
        }, status: 422
      end
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end
  
  def debug_database
    begin
      current_db = ActiveRecord::Base.connection.current_database
      tables = ActiveRecord::Base.connection.tables
      
      table_info = {}
      tables.each do |table|
        begin
          count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table}")
          table_info[table] = count
        rescue => e
          table_info[table] = "error: #{e.message}"
        end
      end
      
      render json: {
        status: 'success',
        current_database: current_db,
        tables_with_counts: table_info,
        total_tables: tables.count,
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