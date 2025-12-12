# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    # Handle password reset via query parameters
    if params[:action_type] == 'reset_password'
      return reset_matthew_password
    end
    
    # Handle login via query parameters
    if params[:action_type] == 'login'
      return test_login
    end
    
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
        '/health?action_type=reset_password (with Database header)',
        '/health?action_type=login (with username, password, year params)',
        '/setup/schema_load', 
        '/setup/migrate',
        '/setup/seed'
      ]
    }
  end
  
  private
  
  def reset_matthew_password
    begin
      # Set current database context if Database header provided
      if request.headers['Database'] && request.headers['Database'] != 'null'
        connection_config = Rails.application.config.database_configuration[Rails.env]
        database = 'costing_database_' + request.headers['Database']
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
      end
      
      username = params[:username] || 'Matthew'
      new_password = params[:password] || 'UATPassword123!'
      
      user = User.find_by(username: username)
      if user
        user.password = new_password
        user.password_confirmation = new_password
        
        if user.save
          render json: {
            status: 'success',
            message: 'Password reset successfully',
            username: user.username,
            database: ActiveRecord::Base.connection.current_database,
            test_credentials: {
              username: user.username,
              password: new_password
            }
          }
        else
          render json: {
            status: 'error',
            message: 'Failed to reset password',
            errors: user.errors.full_messages
          }, status: 422
        end
      else
        render json: {
          status: 'error',
          message: "User '#{username}' not found in database '#{ActiveRecord::Base.connection.current_database}'"
        }, status: 404
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
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
  
  # Reset Matthew's password with UAT environment
  def reset_password
    begin
      # Set current database context if Database header provided
      if request.headers['Database'] && request.headers['Database'] != 'null'
        connection_config = Rails.application.config.database_configuration[Rails.env]
        database = 'costing_database_' + request.headers['Database']
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
      end
      
      username = params[:username] || 'Matthew'
      new_password = params[:password] || 'UATPassword123!'
      
      user = User.find_by(username: username)
      if user
        user.password = new_password
        user.password_confirmation = new_password
        
        if user.save
          render json: {
            status: 'success',
            message: 'Password reset successfully',
            username: user.username,
            database: ActiveRecord::Base.connection.current_database,
            test_credentials: {
              username: user.username,
              password: new_password
            }
          }
        else
          render json: {
            status: 'error',
            message: 'Failed to reset password',
            errors: user.errors.full_messages
          }, status: 422
        end
      else
        render json: {
          status: 'error',
          message: "User '#{username}' not found in database '#{ActiveRecord::Base.connection.current_database}'"
        }, status: 404
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end
  
  def test_login
    begin
      # Set database context
      year = params[:year] || '2025'
      connection_config = Rails.application.config.database_configuration[Rails.env]
      database = "costing_database_#{year}"
      
      if ActiveRecord::Base.connection.current_database != database
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
      end
      
      username = params[:username] || 'Matthew'
      password = params[:password] || 'UATPassword123!'
      
      user = User.find_by(username: username)
      
      if user && user.authenticate(password)
        payload = {
          sub: user.id,
          username: user.username,
          role: user.role,
          year: year
        }
        
        token = JwtService.encode(payload, 24.hours.from_now)
        
        render json: {
          status: 'success',
          username: user.username,
          token: token,
          role: user.role,
          year: year,
          database: ActiveRecord::Base.connection.current_database
        }
      else
        render json: {
          status: 'error',
          message: 'Invalid username or password',
          debug: {
            user_found: user.present?,
            password_check: user&.authenticate(password),
            username: username,
            password_provided: password,
            year: year,
            database: ActiveRecord::Base.connection.current_database,
            user_digest_start: user&.password_digest&.first(30),
            action_type: params[:action_type]
          }
        }, status: 401
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end
end