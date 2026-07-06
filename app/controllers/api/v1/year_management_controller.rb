# frozen_string_literal: true
module Api
  module V1
    class YearManagementController < BaseController
      # Skip DB switch — we always operate on the main railway DB or via raw PG connections
      skip_before_action :set_current_database
      before_action :require_admin_role

      # GET /api/v1/year_management/years
      def years
        conn = PG::Connection.new(ENV['DATABASE_URL'])
        rows = conn.exec("SELECT year, frozen FROM database_years ORDER BY year ASC").to_a
        conn.close
        render json: {
          years: rows.map { |r| { year: r['year'].to_i, frozen: r['frozen'] == 't' } }
        }
      rescue => e
        render json: { error: e.message }, status: 500
      end

      # POST /api/v1/year_management/freeze_and_advance
      # Header: Database: <year_to_freeze>
      # 1. Creates costing_database_{year+1}
      # 2. Runs migrations
      # 3. Copies ALL data (including users) from current year to new year
      # 4. Marks current year frozen, registers new year in database_years
      def freeze_and_advance
        year_header = request.headers['Database'].presence
        return render json: { error: 'Database header (year to freeze) is required' }, status: 422 unless year_header

        current_year = year_header.to_i
        next_year    = current_year + 1
        current_db   = "costing_database_#{current_year}"
        next_db      = "costing_database_#{next_year}"
        main_url     = ENV['DATABASE_URL']&.strip

        return render json: { error: 'DATABASE_URL not configured' }, status: 422 unless main_url.present?

        steps = []

        # 1 — Create next year database
        begin
          admin_conn = PG::Connection.new(main_url)
          admin_conn.exec("CREATE DATABASE \"#{next_db}\"")
          admin_conn.close
          steps << { step: 'create_database', status: 'created', database: next_db }
        rescue PG::DuplicateDatabase
          steps << { step: 'create_database', status: 'already_exists', database: next_db }
        rescue => e
          return render json: { status: 'error', step: 'create_database', message: e.message, steps: steps }, status: 500
        end

        # 2 — Run migrations on next year DB
        begin
          ActiveRecord::Base.establish_connection(swap_db_in_url(main_url, next_db))
          ActiveRecord::MigrationContext.new(Rails.root.join('db/migrate').to_s).migrate
          steps << { step: 'migrate_schema', status: 'ok' }
        rescue => e
          steps << { step: 'migrate_schema', status: 'error', message: e.message }
          restore_main_connection(main_url)
          return render json: { status: 'error', steps: steps }, status: 500
        ensure
          restore_main_connection(main_url)
        end

        # 3 — Copy all data (including users) from current year to next year
        src_conn  = nil
        dest_conn = nil
        begin
          src_conn  = PG::Connection.new(swap_db_in_url(main_url, current_db))
          dest_conn = PG::Connection.new(swap_db_in_url(main_url, next_db))

          skip_tables    = %w[schema_migrations ar_internal_metadata]
          dest_tables    = dest_conn.exec(
            "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
          ).map { |r| r['tablename'] }
          tables_to_copy = dest_tables - skip_tables
          table_results  = {}

          dest_conn.exec("SET session_replication_role = 'replica'")
          tables_to_copy.each { |t| table_results[t] = copy_table(src_conn, dest_conn, t) }
          dest_conn.exec("SET session_replication_role = 'origin'")
          reset_sequences(dest_conn, tables_to_copy)

          steps << { step: 'copy_data', status: 'ok', tables: table_results }
        rescue => e
          dest_conn&.exec("SET session_replication_role = 'origin'") rescue nil
          steps << { step: 'copy_data', status: 'error', message: e.message }
          return render json: { status: 'error', steps: steps }, status: 500
        ensure
          src_conn&.close
          dest_conn&.close
        end

        # 4 — Update database_years registry in main DB
        begin
          main_conn = PG::Connection.new(main_url)
          main_conn.exec(
            "INSERT INTO database_years (year, frozen, created_at, updated_at) " \
            "VALUES (#{next_year}, false, NOW(), NOW()) ON CONFLICT (year) DO NOTHING"
          )
          main_conn.exec(
            "UPDATE database_years SET frozen = true, updated_at = NOW() WHERE year = #{current_year}"
          )
          main_conn.close
          steps << { step: 'update_registry', status: 'ok', frozen_year: current_year, new_year: next_year }
        rescue => e
          steps << { step: 'update_registry', status: 'error', message: e.message }
        end

        render json: { status: 'success', frozen_year: current_year, new_year: next_year, steps: steps }
      end

      private

      def require_admin_role
        render json: { error: 'Admin access required' }, status: 403 unless @current_user&.role == 'admin'
      end

      def swap_db_in_url(url, db_name)
        uri = URI.parse(url)
        uri.path = "/#{db_name}"
        uri.to_s
      end

      def restore_main_connection(main_url)
        ActiveRecord::Base.establish_connection(main_url)
      rescue => e
        Rails.logger.error "Failed to restore main connection: #{e.message}"
      end

      def copy_table(src_conn, dest_conn, table)
        exists = src_conn.exec_params("SELECT to_regclass($1) AS t", ["public.#{table}"]).first['t']
        return 'skipped (not in source)' unless exists

        dest_cols = dest_conn.exec(<<~SQL).each_with_object({}) { |r, h| h[r['column_name']] = r['data_type'] }
          SELECT column_name, data_type FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = '#{table}' ORDER BY ordinal_position
        SQL
        src_cols = src_conn.exec(<<~SQL).each_with_object({}) { |r, h| h[r['column_name']] = r['data_type'] }
          SELECT column_name, data_type FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = '#{table}' ORDER BY ordinal_position
        SQL

        columns   = dest_cols.keys & src_cols.keys
        return 'no matching columns' if columns.empty?

        rows      = src_conn.exec("SELECT #{columns.map { |c| "\"#{c}\"" }.join(', ')} FROM \"#{table}\"")
        row_count = rows.ntuples
        dest_conn.exec("DELETE FROM \"#{table}\"")
        return 'empty' if row_count == 0

        rows.each_slice(100) do |batch|
          col_list = columns.map { |c| "\"#{c}\"" }.join(', ')
          values   = batch.map do |row|
            vals = columns.map do |col|
              v = row[col]
              next 'NULL' if v.nil?
              dest_cols[col]&.include?('integer') && v.include?('.') ? v.to_f.round.to_s : src_conn.escape_literal(v)
            end
            "(#{vals.join(', ')})"
          end.join(', ')
          dest_conn.exec("INSERT INTO \"#{table}\" (#{col_list}) VALUES #{values}")
        end
        row_count
      rescue => e
        "error: #{e.message}"
      end

      def reset_sequences(conn, tables)
        tables.each do |table|
          conn.exec(<<~SQL) rescue nil
            DO $$ DECLARE seq text;
            BEGIN
              seq := pg_get_serial_sequence('"#{table}"', 'id');
              IF seq IS NOT NULL THEN
                PERFORM setval(seq, COALESCE((SELECT MAX(id) FROM "#{table}"), 1));
              END IF;
            END $$;
          SQL
        end
      end
    end
  end
end
