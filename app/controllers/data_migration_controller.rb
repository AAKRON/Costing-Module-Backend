# frozen_string_literal: true
class DataMigrationController < ApplicationController
  before_action :require_admin_key

  # GET /data_migration/inspect_production
  def inspect_production
    prod_url = ENV['PROD_DATABASE_URL']&.strip
    return render json: { error: 'PROD_DATABASE_URL is not configured.' }, status: 422 unless prod_url.present?

    begin
      prod_conn = PG::Connection.new(prod_url)
      db_name   = prod_conn.db

      all_databases = prod_conn.exec(
        "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname"
      ).map { |r| r['datname'] }

      tables = prod_conn.exec(
        "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
      ).map { |r| r['tablename'] }

      table_counts = {}
      tables.each do |t|
        count = prod_conn.exec("SELECT COUNT(*) FROM \"#{t}\"").first['count']
        table_counts[t] = count.to_i
      end

      prod_conn.close

      render json: {
        status: 'success',
        connected_to_database: db_name,
        all_databases_on_server: all_databases,
        tables_in_connected_db: table_counts,
        timestamp: Time.current
      }
    rescue => e
      render json: { status: 'error', message: e.message }, status: 500
    end
  end

  # POST /data_migration/copy_from_production
  # Optional param: ?source_db=costing_database_2026
  def copy_from_production
    prod_url  = ENV['PROD_DATABASE_URL']&.strip
    uat_url   = ENV['DATABASE_URL']&.strip
    source_db = params[:source_db].presence

    return render json: { error: 'PROD_DATABASE_URL is not configured.' }, status: 422 unless prod_url.present?
    return render json: { error: 'DATABASE_URL is not configured.' }, status: 422 unless uat_url.present?

    prod_url = swap_db_in_url(prod_url, source_db) if source_db

    skip_tables = %w[users schema_migrations ar_internal_metadata]
    prod_conn = nil
    uat_conn  = nil

    begin
      prod_conn = PG::Connection.new(prod_url)
      uat_conn  = PG::Connection.new(uat_url)

      uat_tables     = uat_conn.exec(
        "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
      ).map { |r| r['tablename'] }

      tables_to_copy = uat_tables - skip_tables
      results = {}

      # Disable FK constraint enforcement for the session so parent tables
      # can be cleared even when child tables already reference them.
      uat_conn.exec("SET session_replication_role = 'replica'")

      tables_to_copy.each do |table|
        results[table] = copy_table(prod_conn, uat_conn, table)
      end

      uat_conn.exec("SET session_replication_role = 'origin'")

      reset_sequences(uat_conn, tables_to_copy)

      render json: {
        status:    'success',
        message:   'Production data copied to UAT successfully',
        source_db: prod_conn.db,
        skipped:   skip_tables,
        tables:    results,
        timestamp: Time.current
      }
    rescue => e
      uat_conn&.exec("SET session_replication_role = 'origin'")
      render json: { status: 'error', message: e.message, backtrace: e.backtrace.first(5) }, status: 500
    ensure
      prod_conn&.close
      uat_conn&.close
    end
  end

  # POST /data_migration/setup_year_database?year=2025
  def setup_year_database
    year     = params.require(:year)
    new_db   = "costing_database_#{year}"
    uat_url  = ENV['DATABASE_URL']&.strip
    prod_url = ENV['PROD_DATABASE_URL']&.strip

    return render json: { error: 'DATABASE_URL not configured' },      status: 422 unless uat_url.present?
    return render json: { error: 'PROD_DATABASE_URL not configured' }, status: 422 unless prod_url.present?

    steps = []

    begin
      admin_conn = PG::Connection.new(uat_url)
      admin_conn.exec("CREATE DATABASE \"#{new_db}\"")
      admin_conn.close
      steps << { step: 'create_database', status: 'created', database: new_db }
    rescue PG::DuplicateDatabase
      steps << { step: 'create_database', status: 'already_exists', database: new_db }
    rescue => e
      return render json: { status: 'error', step: 'create_database', message: e.message, steps: steps }, status: 500
    end

    original_config = Rails.application.config.database_configuration[Rails.env].dup
    new_config      = original_config.dup.merge('database' => new_db)

    begin
      ActiveRecord::Base.establish_connection(new_config)
      ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate').to_s).migrate
      steps << { step: 'migrate_schema', status: 'ok' }
    rescue => e
      ActiveRecord::Base.establish_connection(original_config)
      return render json: { status: 'error', step: 'migrate_schema', message: e.message, steps: steps }, status: 500
    end

    skip_tables   = %w[users schema_migrations ar_internal_metadata]
    prod_year_url = swap_db_in_url(prod_url, new_db)
    uat_year_url  = swap_db_in_url(uat_url,  new_db)
    prod_conn = nil
    uat_conn  = nil

    begin
      prod_conn = PG::Connection.new(prod_year_url)
      uat_conn  = PG::Connection.new(uat_year_url)

      uat_tables     = uat_conn.exec(
        "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
      ).map { |r| r['tablename'] }

      tables_to_copy = uat_tables - skip_tables
      table_results  = {}

      # Disable FK constraint enforcement for the session so parent tables
      # can be cleared even when child _location_prices tables already reference them.
      uat_conn.exec("SET session_replication_role = 'replica'")

      tables_to_copy.each do |table|
        table_results[table] = copy_table(prod_conn, uat_conn, table)
      end

      uat_conn.exec("SET session_replication_role = 'origin'")

      reset_sequences(uat_conn, tables_to_copy)
      steps << { step: 'copy_data', status: 'ok', tables: table_results }
    rescue => e
      uat_conn&.exec("SET session_replication_role = 'origin'")
      steps << { step: 'copy_data', status: 'error', message: e.message }
    ensure
      prod_conn&.close
      uat_conn&.close
      ActiveRecord::Base.establish_connection(original_config)
    end

    render json: { status: 'success', year: year, database: new_db, steps: steps }
  end

  private

  def swap_db_in_url(url, db_name)
    uri      = URI.parse(url)
    uri.path = "/#{db_name}"
    uri.to_s
  end

  def copy_table(prod_conn, uat_conn, table)
    exists = prod_conn.exec_params(
      "SELECT to_regclass($1) AS t", ["public.#{table}"]
    ).first['t']
    return 'skipped (not in production)' unless exists

    uat_col_info = uat_conn.exec(<<~SQL).each_with_object({}) { |r, h| h[r['column_name']] = r['data_type']; }
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = '#{table}'
      ORDER BY ordinal_position
    SQL

    prod_col_info = prod_conn.exec(<<~SQL).each_with_object({}) { |r, h| h[r['column_name']] = r['data_type']; }
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = '#{table}'
      ORDER BY ordinal_position
    SQL

    columns = uat_col_info.keys & prod_col_info.keys
    return 'no matching columns' if columns.empty?

    prod_rows = prod_conn.exec("SELECT #{columns.map { |c| "\"#{c}\"" }.join(', ')} FROM \"#{table}\"")
    row_count = prod_rows.ntuples

    uat_conn.exec("DELETE FROM \"#{table}\"")
    return 'empty' if row_count == 0

    prod_rows.each_slice(100) do |batch|
      col_list    = columns.map { |c| "\"#{c}\"" }.join(', ')
      values_list = batch.map do |row|
        vals = columns.map do |col|
          v        = row[col]
          uat_type = uat_col_info[col]
          if v.nil?
            'NULL'
          elsif uat_type&.include?('integer') && v.include?('.')
            v.to_f.round.to_s
          else
            prod_conn.escape_literal(v)
          end
        end
        "(#{vals.join(', ')})"
      end.join(', ')
      uat_conn.exec("INSERT INTO \"#{table}\" (#{col_list}) VALUES #{values_list}")
    end

    row_count
  rescue => e
    "error: #{e.message}"
  end

  def reset_sequences(uat_conn, tables)
    tables.each do |table|
      uat_conn.exec(<<~SQL)
        DO $$
        DECLARE seq text;
        BEGIN
          seq := pg_get_serial_sequence('"#{table}"', 'id');
          IF seq IS NOT NULL THEN
            PERFORM setval(seq, COALESCE((SELECT MAX(id) FROM "#{table}"), 1));
          END IF;
        END $$;
      SQL
    rescue PG::Error
    end
  end
end
