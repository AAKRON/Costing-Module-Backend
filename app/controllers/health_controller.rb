# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    if params[:action_type] == 'reset_password'
      return reset_matthew_password
    end

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
        '/health/diagnostics',
        '/health/list_users (GET, year param or Database header, X-Admin-Key)',
        '/health/copy_users_to_year (POST, ?target_year=2026, X-Admin-Key)',
        '/health/reset_password (POST, Database header)'
      ]
    }
  end

  # GET /health/diagnostics
  def diagnostics
    conn = ActiveRecord::Base.connection
    begin
      app_constants = conn.execute("SELECT name, value FROM app_constants ORDER BY name").to_a rescue []
      blank_jobs_count  = conn.execute("SELECT COUNT(*) AS c FROM blank_jobs").first['c'] rescue 'error'
      blanks_total      = conn.execute("SELECT COUNT(*) AS c FROM blanks").first['c'] rescue 'error'
      blanks_with_type  = conn.execute("SELECT COUNT(*) AS c FROM blanks WHERE blank_type_id != 0").first['c'] rescue 'error'
      blank_types       = conn.execute("SELECT type_number, description FROM blank_types ORDER BY type_number").to_a rescue []

      bcv = conn.execute(<<~SQL).first rescue {}
        SELECT COUNT(*) AS total,
               COUNT(CASE WHEN total_blank_cost_for_price > 0 THEN 1 END) AS nonzero_price,
               COUNT(CASE WHEN type_number = 1 THEN 1 END) AS type1_count
        FROM blank_cost_views
      SQL

      bcv_sample = conn.execute(<<~SQL).to_a rescue []
        SELECT blank_number, type_number, total_blank_cost_for_price, total_blank_cost_for_inventory
        FROM blank_cost_views WHERE total_blank_cost_for_price > 0 LIMIT 5
      SQL

      iwbpcv = conn.execute(<<~SQL).first rescue {}
        SELECT COUNT(*) AS total,
               COUNT(CASE WHEN total_blank_cost_for_price > 0 THEN 1 END) AS nonzero_price
        FROM item_with_blank_per_cost_views
      SQL

      render json: {
        app_constants: app_constants,
        blank_jobs_count: blank_jobs_count,
        blanks_total: blanks_total,
        blanks_with_non_zero_type: blanks_with_type,
        blank_types: blank_types,
        blank_cost_views: {
          total_rows: bcv['total'], rows_with_nonzero_price_cost: bcv['nonzero_price'],
          rows_with_type_number_1: bcv['type1_count'], sample_nonzero: bcv_sample
        },
        item_with_blank_per_cost_views: {
          total_rows: iwbpcv['total'], rows_with_nonzero_price_cost: iwbpcv['nonzero_price']
        }
      }
    rescue => e
      render json: { error: e.message, backtrace: e.backtrace.first(5) }, status: 500
    end
  end

  # GET /health/list_users?year=2025  (or Database header)
  def list_users
    return render json: { error: 'Unauthorized' }, status: 401 unless valid_admin_key?

    year = params[:year] || request.headers['Database']
    main_url = ENV['DATABASE_URL']&.strip
    return render json: { error: 'DATABASE_URL not configured' }, status: 422 unless main_url.present?

    if year.present?
      db_name = year.to_s.start_with?('costing_database_') ? year.to_s : "costing_database_#{year}"
      conn = PG::Connection.new(swap_db_in_url(main_url, db_name))
    else
      conn = PG::Connection.new(main_url)
      db_name = 'railway'
    end

    rows = conn.exec("SELECT id, username, role FROM users ORDER BY username").to_a
    conn.close

    render json: {
      database: db_name,
      user_count: rows.size,
      users: rows.map { |r| { id: r['id'], username: r['username'], role: r['role'] } }
    }
  rescue => e
    render json: { error: e.message }, status: 500
  end

  # POST /health/copy_users_to_year?target_year=2026&source_years=2019,2020
  # Uses raw PG; avoids ON CONFLICT since older DBs may lack a unique index on username.
  def copy_users_to_year
    return render json: { error: 'Unauthorized' }, status: 401 unless valid_admin_key?

    target_year  = params[:target_year] || params[:year] || '2026'
    main_url     = ENV['DATABASE_URL']&.strip
    return render json: { error: 'DATABASE_URL not configured' }, status: 422 unless main_url.present?

    source_years = params[:source_years]&.split(',') || (2019..2025).map(&:to_s)
    results      = {}

    target_url  = swap_db_in_url(main_url, "costing_database_#{target_year}")
    target_conn = PG::Connection.new(target_url)

    # Detect whether target stores role as integer or string
    sample_role         = target_conn.exec("SELECT role FROM users LIMIT 1").first&.dig('role').to_s
    target_uses_int_role = sample_role =~ /\A\d+\z/

    source_years.each do |yr|
      src_db = "costing_database_#{yr}"
      begin
        src_conn = PG::Connection.new(swap_db_in_url(main_url, src_db))
        rows     = src_conn.exec("SELECT username, password_digest, role FROM users").to_a
        src_conn.close

        year_results = []
        rows.each do |row|
          username = row['username']
          next if username.to_s.downcase == 'matthew'

          # Normalize role value to match target schema
          raw_role = row['role'].to_s
          if target_uses_int_role
            mapped_role = case raw_role
                          when 'admin' then '1'
                          when 'user'  then '0'
                          else raw_role
                          end
          else
            mapped_role = case raw_role
                          when '1', 'true'  then 'admin'
                          when '0', 'false' then 'user'
                          else raw_role.presence || 'admin'
                          end
          end

          # Check existence without relying on a unique index
          exists = target_conn.exec_params(
            "SELECT 1 FROM users WHERE username = $1 LIMIT 1", [username]
          ).ntuples > 0

          if exists
            year_results << { username: username, status: 'already_exists' }
          else
            target_conn.exec_params(
              "INSERT INTO users (username, password_digest, role, created_at, updated_at) " \
              "VALUES ($1, $2, $3, NOW(), NOW())",
              [username, row['password_digest'], mapped_role]
            )
            year_results << { username: username, status: 'created', role: mapped_role }
          end
        end
        results[yr] = year_results
      rescue => e
        results[yr] = { error: e.message }
      end
    end

    final_users = target_conn.exec("SELECT username, role FROM users ORDER BY username").to_a
    target_conn.close

    render json: {
      status: 'done',
      target_year: target_year,
      target_database: "costing_database_#{target_year}",
      results_by_source_year: results,
      final_users_in_target: final_users.map { |r| { username: r['username'], role: r['role'] } }
    }
  rescue => e
    render json: { error: e.message }, status: 500
  end

  # POST /health/create_user
  def create_user
    return render json: { error: 'Not allowed in production' }, status: 403 if Rails.env.production?
    begin
      user = User.create!(
        username: 'testuser', password: 'TestPass123', password_confirmation: 'TestPass123', role: 'admin'
      )
      render json: { status: 'success', message: 'Test user created successfully',
                     user: { username: user.username, role: user.role },
                     login: { username: 'testuser', password: 'TestPass123' } }
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end

  # POST /health/reset_password
  def reset_password
    begin
      switch_database(request.headers['Database'])
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
          test_credentials: { username: user.username, password: new_password }
        }
      else
        render json: { status: 'error', message: 'Failed to save user', errors: user.errors.full_messages }, status: 422
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end

  private

  def valid_admin_key?
    provided = request.headers['X-Admin-Key'].presence || params[:admin_key].presence
    expected = ENV['ADMIN_KEY'].presence
    expected && provided && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
  end

  def swap_db_in_url(url, db_name)
    uri = URI.parse(url)
    uri.path = "/#{db_name}"
    uri.to_s
  end

  def switch_database(year_header)
    return unless year_header.present? && year_header != 'null'
    database = year_header.to_s.start_with?('costing_database_') ? year_header : "costing_database_#{year_header}"
    if ENV['DATABASE_URL'].present?
      uri = URI.parse(ENV['DATABASE_URL'])
      uri.path = "/#{database}"
      ActiveRecord::Base.establish_connection(uri.to_s)
    else
      config = ActiveRecord::Base.connection_db_config.configuration_hash.merge(database: database)
      ActiveRecord::Base.establish_connection(config)
    end
  end

  def reset_matthew_password
    begin
      switch_database(request.headers['Database'])
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
          test_credentials: { username: user.username, password: new_password }
        }
      else
        render json: { status: 'error', message: 'Failed to save user', errors: user.errors.full_messages }, status: 422
      end
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end
end
