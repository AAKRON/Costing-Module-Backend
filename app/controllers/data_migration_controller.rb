# frozen_string_literal: true
class DataMigrationController < ApplicationController

  # POST /data_migration/copy_from_production
  # Requires PROD_DATABASE_URL set in Railway environment variables.
  # Copies all data tables from production into UAT, preserving the UAT users table.
  def copy_from_production
    prod_url = ENV['PROD_DATABASE_URL']&.strip
    uat_url  = ENV['DATABASE_URL']&.strip

    return render json: { error: 'PROD_DATABASE_URL is not configured. Add it in Railway → UAT service → Variables.' }, status: 422 unless prod_url.present?
    return render json: { error: 'DATABASE_URL is not configured.' }, status: 422 unless uat_url.present?

    # Tables to never touch — preserve UAT user accounts and Rails internals
    skip_tables = %w[users schema_migrations ar_internal_metadata]

    prod_conn = nil
    uat_conn  = nil

    begin
      prod_conn = PG::Connection.new(prod_url)
      uat_conn  = PG::Connection.new(uat_url)

      # Get list of tables in UAT (source of truth for schema)
      uat_tables = uat_conn.exec(
        "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
      ).map { |r| r['tablename'] }

      tables_to_copy = uat_tables - skip_tables
      results = {}

      tables_to_copy.each do |table|
        results[table] = copy_table(prod_conn, uat_conn, table)
      end

      # Reset sequences so new records don't get ID conflicts
      reset_sequences(uat_conn, tables_to_copy)

      render json: {
        status:    'success',
        message:   'Production data copied to UAT successfully',
        skipped:   skip_tables,
        tables:    results,
        timestamp: Time.current
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
    # Check table exists in prod
    exists = prod_conn.exec_params(
      "SELECT to_regclass($1) AS t", ["public.#{table}"]
    ).first['t']
    return 'skipped (not in production)' unless exists

    prod_rows = prod_conn.exec("SELECT * FROM \"#{table}\"")
    row_count = prod_rows.ntuples

    # Always clear UAT table first
    uat_conn.exec("DELETE FROM \"#{table}\"")

    return 'empty' if row_count == 0

    columns = prod_rows.fields

    # Insert in batches of 100
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
      # Table has no id sequence — skip
    end
  end
end
