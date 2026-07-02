# frozen_string_literal: true
class DataMigrationController < ApplicationController

  # GET /data_migration/inspect_production
  # Shows all databases on the production server and tables in the default DB.
  def inspect_production
    prod_url = ENV['PROD_DATABASE_URL']&.strip
    return render json: { error: 'PROD_DATABASE_URL is not configured.' }, status: 422 unless prod_url.present?

    begin
      prod_conn = PG::Connection.new(prod_url)
      db_name   = prod_conn.db

      # List ALL databases on this Postgres server
      all_databases = prod_conn.exec(
        "SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname"
      ).map { |r| r['datname'] }

      # List tables in the currently connected database
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
  # Requires PROD_DATABASE_URL set in Railway environment variables.
  # By default copies from the 'railway' database. Pass ?source_db=name to copy from a different database.
  def copy_from_production
    prod_url   = ENV['PROD_DATABASE_URL']&.strip
    uat_url    = ENV['DATABASE_URL']&.strip
    source_db  = params[:source_db].presence

    return render json: { error: 'PROD_DATABASE_URL is not configured.' }, status: 422 unless prod_url.present?
    return render json: { error: 'DATABASE_URL is not configured.' }, status: 422 unless uat_url.present?

    # If a specific source database is requested, swap it into the URL
    if source_db
      prod_url = prod_url.sub(%r{/[^/]+\z}, "/#{source_db}")
    end

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

      tables_to_copy.each do |table|
        results[table] = copy_table(prod_conn, uat_conn, table)
      end

      reset_sequences(uat_conn, tables_to_copy)

      render json: {
        status:        'success',
        message:       'Production data copied to UAT successfully',
        source_db:     prod_conn.db,
        skipped:       skip_tables,
        tables:        results,
        timestamp:     Time.current
      }

    rescue => e
      render json: { status: 'error', message: e.message, backtrace: e.backtrace.first(5) }, status: 500
    ensure
      prod_conn&.close
      uat_conn&.close
    end
  end

  private

  def copy_table(prod_conn, uat_conn, table)
    exists = prod_conn.exec_params(
      "SELECT to_regclass($1) AS t", ["public.#{table}"]
    ).first['t']
    return 'skipped (not in production)' unless exists

    prod_rows = prod_conn.exec("SELECT * FROM \"#{table}\"")
    row_count = prod_rows.ntuples

    uat_conn.exec("DELETE FROM \"#{table}\"")
    return 'empty' if row_count == 0

    columns = prod_rows.fields

    prod_rows.each_slice(100) do |batch|
      col_list    = columns.map { |c| "\"#{c}\"" }.join(', ')
      values_list = batch.map do |row|
        vals = columns.map do |col|
          v = row[col]
          v.nil? ? 'NULL' : prod_conn.escape_literal(v)
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
