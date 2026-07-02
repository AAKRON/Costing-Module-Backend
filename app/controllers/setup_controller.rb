# frozen_string_literal: true
class SetupController < ApplicationController
  before_action :set_current_database

  def schema_load
    begin
      load(Rails.root.join('db/schema.rb'))

      render json: {
        status: 'success',
        message: 'Database schema loaded successfully from schema.rb',
        timestamp: Time.current
      }
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  def migrate
    begin
      ActiveRecord::Migration.verbose = true

      migration_context = ActiveRecord::MigrationContext.new(
        Rails.root.join('db/migrate'),
        ActiveRecord::SchemaMigration
      )
      migration_context.migrate

      render json: {
        status: 'success',
        message: 'Database migrations completed successfully',
        timestamp: Time.current
      }
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  def seed
    begin
      Rails.application.load_seed

      render json: {
        status: 'success',
        message: 'Database seeding completed successfully',
        timestamp: Time.current
      }
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  def create_test_user
    begin
      user = User.find_or_initialize_by(username: 'testuser')
      user.assign_attributes(
        password: 'TestPassword123!',
        password_confirmation: 'TestPassword123!',
        role: 'admin'
      )

      if user.save
        render json: {
          status: 'success',
          message: user.previously_new_record? ? 'Test user created' : 'Test user updated',
          login_credentials: { username: 'testuser', password: 'TestPassword123!' },
          timestamp: Time.current
        }
      else
        render json: {
          status: 'error',
          message: 'Failed to create user',
          errors: user.errors.full_messages,
          timestamp: Time.current
        }, status: 422
      end
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  def reset_user_password
    begin
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
          test_credentials: { username: user.username, password: new_password },
          timestamp: Time.current
        }
      else
        render json: {
          status: 'error',
          message: 'Failed to save user',
          errors: user.errors.full_messages,
          timestamp: Time.current
        }, status: 422
      end
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  def debug_database
    begin
      current_db = ActiveRecord::Base.connection.current_database
      tables     = ActiveRecord::Base.connection.tables

      table_info = {}
      tables.each do |table|
        begin
          count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM #{table}")
          table_info[table] = count
        rescue => e
          table_info[table] = "error: #{e.message}"
        end
      end

      render json: {
        status: 'success',
        current_database: current_db,
        tables_with_counts: table_info,
        total_tables: tables.count,
        timestamp: Time.current
      }
    rescue => e
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end

  private

  def set_current_database
    connection_config = Rails.application.config.database_configuration[Rails.env]
    database = ENV['PG_DB_DEV']

    if request.headers['Database'] && request.headers['Database'] != 'null' && request.headers['Database'] != Time.now.year.to_s
      database = 'costing_module_db_' + request.headers['Database']
    end

    if database && ActiveRecord::Base.connection.current_database != database
      connection_config['database'] = database
      ActiveRecord::Base.establish_connection(connection_config)
    end

    Rails.logger.debug "Selected database #{database}"
  end
end
