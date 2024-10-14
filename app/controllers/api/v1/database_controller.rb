module Api
    module V1
        class DatabaseController < ApplicationController
            before_action :set_current_database

            def list_databases
                database_years = DatabaseYear.all
                render json: database_years, status: :ok
            end

            def backup
                current_year = Date.current.year + 1
                cur_database_year = DatabaseYear.where(year: current_year).first

                if cur_database_year.present?
                    render json: { message: "Backup for #{current_year} already made" }, status: :bad_request
                else
                    system("rake db:backup")
                    DatabaseYear.new(year: current_year).save
                    render json: { message: "Backup completed." }
                end
            end

            private

            def set_current_database
                connection_config = Rails.application.config.database_configuration[Rails.env]
                database = ENV['PG_DB_PROD']
                current_year = get_current_year
                if request.headers['Database'] && request.headers['Database'] != 'null' && request.headers['Database'] != current_year
                    database = database + '_' + request.headers['Database']
                end

                if ActiveRecord::Base.connection.current_database != database
                    connection_config['database'] = database
                    connection_config['adapter'] = 'postgresql'
                    connection_config['pool'] = 10
                    connection_config['timeout'] = 50000
                    connection_config['host'] = ENV['PGHOST']
                    connection_config['port'] = ENV['PGPORT']
                    connection_config['username'] = ENV['PGUSER']
                    connection_config['password'] = ENV['PGPASSWORD']
                    ActiveRecord::Base.establish_connection(connection_config)
                end
            end

            def get_current_year
                if @database_location_exists
                    max_db_year = DatabaseYear.order('year DESC').first
                    return max_db_year.year
                end
                return Date.current.year.to_s
            end
        end
    end
end
