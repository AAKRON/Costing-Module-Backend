module Api
    module V1
        class DatabaseController < ApplicationController
            def list_databases
                connection_config = Rails.application.config.database_configuration[Rails.env]
                database = ENV['PG_DB_DEV']
                if ActiveRecord::Base.connection.current_database != database
                    connection_config['database'] = database
                    ActiveRecord::Base.establish_connection(connection_config)
                end

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
                    # DatabaseYear.new(year: current_year).save
                    render json: { message: "Backup completed." }
                end
            end
        end
    end
end
