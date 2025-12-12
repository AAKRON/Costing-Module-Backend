# frozen_string_literal: true
class SimpleAuthController < ActionController::API
  
  def login_2025
    # Connect directly to 2025 database
    connection_config = Rails.application.config.database_configuration[Rails.env]
    connection_config['database'] = 'costing_database_2025'
    ActiveRecord::Base.establish_connection(connection_config)
    
    # Get credentials
    username = params[:username]
    password = params[:password]
    
    # Find and authenticate user
    user = User.find_by(username: username)
    
    if user && user.authenticate(password)
      # Create simple token (no JWT complexity for now)
      token = SecureRandom.hex(32)
      
      render json: {
        success: true,
        username: user.username,
        role: user.role,
        token: token,
        year: '2025',
        database: ActiveRecord::Base.connection.current_database
      }
    else
      render json: {
        success: false,
        message: 'Invalid credentials',
        debug: {
          username_provided: username,
          user_found: user.present?,
          database: ActiveRecord::Base.connection.current_database
        }
      }, status: 401
    end
    
  rescue => e
    db_name = begin
      ActiveRecord::Base.connection.current_database
    rescue
      'unknown'
    end
    
    render json: {
      success: false,
      error: e.message,
      database: db_name
    }, status: 500
  end
end