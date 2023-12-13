# frozen_string_literal: true
include ActionController::HttpAuthentication::Token::ControllerMethods
include ActionController::MimeResponds

class Api::V1::BaseController < ApplicationController
  before_action :destroy_session
  before_action :set_raven_context
  before_action :set_current_database

  private

  def set_current_database
    connection_config = Rails.application.config.database_configuration[Rails.env]
    database = ENV['PG_DB_DEV']

    if request.headers['Database'] && request.headers['Database'] != 'null' && request.headers['Database'] != Time.now.year.to_s && request.headers['Database'] != 2024
        database = database + '_' + request.headers['Database']
    end

    if ActiveRecord::Base.connection.current_database != database
        connection_config['database'] = database
        ActiveRecord::Base.establish_connection(connection_config)
    end

    # logger.debug "Selected database #{database}"
    # logger.debug "current_database #{ActiveRecord::Base.connection.current_database}"
  end

  def restrict_access
    (unauthorized! && return) unless get_key_by_token
  end

  def get_key_by_token
    restrict_access_by_header || restrict_access_by_params
  end

  def restrict_access_by_header
    return true if @current_user
    authenticate_with_http_token do |token|
      @current_user = User.find_by_token(token)
    end
  end

  def restrict_access_by_params
    return true if @current_user
    @current_user = User.find_by_token(params[:user_token])
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
