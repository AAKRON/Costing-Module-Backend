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
    database = ENV['PG_DB_DEV'].presence || ActiveRecord::Base.connection.current_database

    if request.headers['Database'].present? &&
       request.headers['Database'] != 'null' &&
       request.headers['Database'] != Time.now.year.to_s
      database = 'costing_database_' + request.headers['Database']
    end

    return if ActiveRecord::Base.connection.current_database == database

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

  # Blocks write requests to frozen years. Reads database_years from the main
  # railway DB via a direct PG connection, independent of the per-request DB switch.
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
    %w[POST PUT PATCH DELETE].include?(request.method)
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
