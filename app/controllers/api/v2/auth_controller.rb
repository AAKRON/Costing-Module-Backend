# frozen_string_literal: true
module Api
  module V2
    class AuthController < ApplicationController
      
      def login
        begin
          # Set database context from year parameter or header
          year = params[:year] || request.headers['Database'] || '2025'
          set_database_for_year(year)
          
          username = params[:username]
          password = params[:password]
          
          # Find and authenticate user
          user = User.find_by(username: username)
          
          # Debug info
          user_found = user.present?
          password_valid = user&.authenticate(password)
          
          if user && user.authenticate(password)
            # Create JWT token
            payload = {
              sub: user.id,
              username: user.username,
              role: user.role,
              year: year,
              database: ActiveRecord::Base.connection.current_database
            }
            
            token = JwtService.encode(payload, 24.hours.from_now)
            
            render json: {
              status: 'success',
              username: user.username,
              token: token,
              role: user.role,
              year: year,
              database: ActiveRecord::Base.connection.current_database,
              message: "Logged into #{year} successfully"
            }
          else
            render json: {
              status: 'error', 
              message: 'Invalid username or password',
              year: year,
              database: ActiveRecord::Base.connection.current_database
            }, status: 401
          end
          
        rescue => e
          render json: {
            status: 'error',
            message: e.message,
            year: year || 'unknown'
          }, status: 500
        end
      end
      
      def switch_year
        begin
          new_year = params[:year]
          return render json: { error: 'Year required' }, status: 400 unless new_year
          
          # Authenticate current token
          auth_header = request.headers['Authorization']
          return render json: { error: 'Authorization header required' }, status: 401 unless auth_header
          
          token = auth_header.split(' ').last
          payload = JwtService.decode(token)
          return render json: { error: 'Invalid token' }, status: 401 unless payload
          
          # Set new database
          set_database_for_year(new_year)
          
          # Verify user exists in new year database
          user = User.find_by(id: payload[:sub])
          return render json: { error: 'User not found in this year' }, status: 404 unless user
          
          # Create new token for new year
          new_payload = payload.merge(
            year: new_year,
            database: ActiveRecord::Base.connection.current_database
          )
          
          new_token = JwtService.encode(new_payload, 24.hours.from_now)
          
          render json: {
            status: 'success',
            token: new_token,
            year: new_year,
            database: ActiveRecord::Base.connection.current_database,
            message: "Switched to #{new_year} successfully"
          }
          
        rescue => e
          render json: {
            status: 'error',
            message: e.message
          }, status: 500
        end
      end
      
      private
      
      def login_endpoint?
        action_name == 'login'
      end
      
      def set_database_for_year(year)
        connection_config = Rails.application.config.database_configuration[Rails.env]
        database = "costing_database_#{year}"
        
        if ActiveRecord::Base.connection.current_database != database
          connection_config['database'] = database
          ActiveRecord::Base.establish_connection(connection_config)
        end
        
        Rails.logger.info "Connected to database: #{ActiveRecord::Base.connection.current_database} for year #{year}"
      end
    end
  end
end year #{year}"
      end
    end
  end
end