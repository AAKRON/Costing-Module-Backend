# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::MimeResponds
  include ActionView::Rendering

  append_view_path Rails.root.join('app', 'views')

  rescue_from Exception do |e|
    render json: { error: e.class.to_s, message: e.message, backtrace: e.backtrace&.first(10) }, status: 500
  end

  before_action :destroy_session
  before_action :set_sentry_context
  before_action :set_current_database
  before_action :restrict_access

  private

  def set_current_database
    database = ENV['PG_DB_DEV'].presence || ActiveRecord::Base.connection.current_database

    if request.headers['Database'].present? &&
       request.headers['Database'] != 'null' &&
       request.headers['Database'] != Time.now.year.to_s
      database = 'costing_database_' + request.headers['Database']
    end

    return if ActiveRecord::Base.connection.current_database == database

    # Rails 7.2: don't mutate the frozen config object — build a new connection spec
    if ENV['DATABASE_URL'].present?
      uri = URI.parse(ENV['DATABASE_URL'])
      uri.path = "/#{database}"
      ActiveRecord::Base.establish_connection(uri.to_s)
    else
      config = ActiveRecord::Base.connection_db_config.configuration_hash.merge(database: database)
      ActiveRecord::Base.establish_connection(config)
    end
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

  def set_sentry_context
    Sentry.set_user(id: @current_user.id, username: @current_user.username) if @current_user
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end

  def set_user_access_level
    render json: { message: 'Permission Denied' }, status: :bad_request unless @current_user.role == 'admin'
  end
end
