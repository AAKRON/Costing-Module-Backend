# frozen_string_literal: true
include ActionController::HttpAuthentication::Token::ControllerMethods
include ActionController::MimeResponds

class Api::V1::BaseController < ApplicationController
  before_action :destroy_session
  before_action :set_raven_context
  before_action :set_current_database

  private

  def set_current_database
    # UAT/single-DB environments: skip year switching entirely
    return if ENV['SINGLE_DATABASE_MODE'] == 'true'

    connection_config = Rails.application.config.database_configuration[Rails.env]
    database = ENV['PG_DB_DEV'] || ActiveRecord::Base.connection.current_database

    if request.headers['Database'] && request.headers['Database'] != 'null' && request.headers['Database'] != Time.now.year.to_s
        database = 'costing_database_' + request.headers['Database']
    end

    if ActiveRecord::Base.connection.current_database != database
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
    end

    Rails.logger.debug "Selected database #{database}"
    Rails.logger.debug "current_database #{ActiveRecord::Base.connection.current_database}"
  end

  def restrict_access
    (unauthorized! && return) unless authenticate_jwt_token
  end

  def authenticate_jwt_token
    return true if @current_user
    
    auth_header = request.headers['Authorization']
    return false unless auth_header && auth_header.start_with?('Bearer ')
    
    token = auth_header.split(' ').last
    payload = JwtService.decode(token)
    return false unless payload
    
    @current_user = User.find_by(id: payload[:sub])
    !!@current_user
  rescue StandardError => e
    Rails.logger.warn "JWT authentication error: #{e.message}"
    false
  end

  def unauthorized!
    render json: { message: 'Not Authorized' }, status: 401
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def set_pagination_header(total_count)
    response.headers['X-Total-Count'] = total_count.to_s
    response.headers['Access-Control-Expose-Headers'] = 'X-Total-Count'
  end

  def set_raven_context
    Raven.user_context(id: @current_user.id, username: @current_user.username) if @current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def set_user_access_level
    render json: { message: 'Permission Denied' }, status: :bad_request unless @current_user.role == 'admin'
  end
end
