# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    # Handle password reset via query parameters
    if params[:action_type] == 'reset_password'
      return reset_matthew_password
    end

    # Handle login via query parameters
    if params[:action_type] == 'login'
      begin
        db_name = ActiveRecord::Base.connection.current_database rescue 'error_getting_db'
        return render json: {
          status: 'debug',
          message: 'Login logic triggered',
          params: params.to_h,
          database_before: db_name
        }
      rescue => e
        return render json: {
          status: 'error',
          message: 'Debug failed',
          error: e.message,
          backtrace: e.backtrace.first(3)
        }, status: 500
      end
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
        '/health?action_type=reset_password (with optional username & password params)',
        '/setup/schema_load',
        '/setup/migrate',
        '/setup/seed',
        '/setup/debug_database'
      ]
    }
  end

  # POST /health/create_user
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

  # POST /health/reset_password
  # Creates the user if they don't exist yet (safe for first-time UAT setup)
  def reset_password
    begin
      if request.headers['Database'] && request.headers['Database'] != 'null'
        connection_config = Rails.application.config.database_configuration[Rails.env]
        database = 'costing_database_' + request.headers['Database']
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
      end

      username     = params[:username] || 'Matthew'
      new_password = params[:password] || 'UATPassword123!'

      user = User.find_or_initialize_by(username: username)
      user.password              = new_password
      user.password_confirmation = new_password
      user.role                ||= 'admin'

      if user.save
        render json: {
          status: 'success',
          message: user.previously_new_record? ? 'User created and password set' : 'Password reset successfully',
          username: user.username,
          database: (ActiveRecord::Base.connection.current_database rescue 'unknown'),
          test_credentials: {
            username: user.username,
            password: new_password
          }
        }
      else
        render json: {
          status: 'error',
          message: 'Failed to save user',
          errors: user.errors.full_messages
        }, status: 422
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end

  private

  def reset_matthew_password
    begin
      if request.headers['Database'] && request.headers['Database'] != 'null'
        connection_config = Rails.application.config.database_configuration[Rails.env]
        database = 'costing_database_' + request.headers['Database']
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
      end

      username     = params[:username] || 'Matthew'
      new_password = params[:password] || 'UATPassword123!'

      user = User.find_or_initialize_by(username: username)
      user.password              = new_password
      user.password_confirmation = new_password
      user.role                ||= 'admin'

      if user.save
        render json: {
          status: 'success',
          message: user.previously_new_record? ? 'User created and password set' : 'Password reset successfully',
          username: user.username,
          database: (ActiveRecord::Base.connection.current_database rescue 'unknown'),
          test_credentials: {
            username: user.username,
            password: new_password
          }
        }
      else
        render json: {
          status: 'error',
          message: 'Failed to save user',
          errors: user.errors.full_messages
        }, status: 422
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end

  def test_login
    begin
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
            username: username,
            year: year,
            database: ActiveRecord::Base.connection.current_database
          }
        }, status: 401
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end
end
