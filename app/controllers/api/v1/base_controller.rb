# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::MimeResponds

  rescue_from StandardError do |e|
    render json: { error: e.class.name, message: e.message, trace: e.backtrace&.first(5) }, status: 500
  end

  before_action :destroy_session
  before_action :set_sentry_context
  before_action :set_current_database
  before_action :restrict_access
  before_action :reject_if_year_frozen, if: :write_request?

  private

  def set_current_database
    raw_header = request.headers['Database']

    if raw_header.present? && raw_header != 'null'
      database = 'costing_database_' + raw_header
    else
      database = ENV['PG_DB_DEV'].presence
      database ||= begin
        ActiveRecord::Base.connection.current_database
      rescue
        nil
      end
    end

    return unless database.present?

    # Short-circuit if the pool is already on the right database.
    # If the current connection is broken (e.g. post-rollback), disconnect it first.
    begin
      return if ActiveRecord::Base.connection.current_database == database
    rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
      ActiveRecord::Base.connection_pool.disconnect! rescue nil
    end

    if ENV['DATABASE_URL'].present?
      uri = URI.parse(ENV['DATABASE_URL'])
      uri.path = "/#{database}"
      ActiveRecord::Base.establish_connection(uri.to_s)
    else
      config = ActiveRecord::Base.connection_db_config.configuration_hash.merge(database: database)
      ActiveRecord::Base.establish_connection(config)
    end

    # Probe immediately so a missing database raises here rather than deep in a controller.
    ActiveRecord::Base.connection.current_database

  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
    # Database was dropped (e.g. after rollback_freeze). Reset pool to main so the
    # next request isn't also broken, then return a clear error to the client.
    ActiveRecord::Base.connection_pool.disconnect! rescue nil
    begin
      ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']) if ENV['DATABASE_URL'].present?
    rescue
      nil
    end
    render json: {
      error: "Database '#{database}' does not exist. This year may have been rolled back. Please log out and select an active year.",
      code: 'DATABASE_NOT_FOUND'
    }, status: 422
  end

  def restrict_access
    return if request.method == 'OPTIONS'
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

  def reject_if_year_frozen
    year_header = request.headers['Database'].presence
    return unless year_header && year_header != 'null'

    year = year_header.to_i
    return unless year > 0

    main_url = ENV['DATABASE_URL']
    return unless main_url.present?

    begin
      conn   = PG::Connection.new(main_url)
      result = conn.exec_params("SELECT frozen FROM database_years WHERE year = $1", [year]).first
      conn.close
      if result && result['frozen'] == 't'
        render json: { error: "Year #{year} is frozen and read-only" }, status: 403
      end
    rescue => e
      Rails.logger.warn "Year frozen check failed: #{e.message}"
    end
  end

  def write_request?
    return false if controller_name == 'sessions'
    %w[POST PUT PATCH DELETE].include?(request.method)
  end

  def unauthorized!
    debug = {}
    begin
      auth_header = request.headers['Authorization']
      token = auth_header&.start_with?('Bearer ') ? auth_header.split(' ').last : nil
      payload = token ? JwtService.decode(token) : nil
      debug = {
        has_auth_header: auth_header.present?,
        token_present: token.present?,
        token_valid: payload.present?,
        user_id_in_token: payload&.dig(:sub),
        user_found: payload ? User.find_by(id: payload[:sub]).present? : false,
        database_header: request.headers['Database'],
        current_database: ActiveRecord::Base.connection.current_database,
        request_method: request.method,
      }
    rescue => e
      debug = { error: e.message }
    end
    render json: { message: 'Not Authorized', debug: debug }, status: 401
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
