# frozen_string_literal: true
class DataMigrationController < ApplicationController
  # No authentication required for UAT data setup
  
  def copy_from_production
    return render json: { error: 'Not allowed in production' }, status: 403 if Rails.env.production?
    
    begin
      # Connect to production database
      prod_config = {
        adapter: 'postgresql',
        host: ENV['PROD_DB_HOST'],
        database: ENV['PROD_DB_NAME'],
        username: ENV['PROD_DB_USER'],
        password: ENV['PROD_DB_PASSWORD'],
        port: ENV['PROD_DB_PORT'] || 5432
      }
      
      prod_connection = ActiveRecord::Base.establish_connection(prod_config).connection
      
      copied_tables = []
      
      # Copy Users
      if copy_table_data(prod_connection, 'users', User)
        copied_tables << 'users'
      end
      
      # Copy Items
      if defined?(Item) && copy_table_data(prod_connection, 'items', Item)
        copied_tables << 'items'
      end
      
      # Copy Blanks
      if defined?(Blank) && copy_table_data(prod_connection, 'blanks', Blank)
        copied_tables << 'blanks'
      end
      
      # Copy Vendors
      if defined?(Vendor) && copy_table_data(prod_connection, 'vendors', Vendor)
        copied_tables << 'vendors'
      end
      
      # Copy Raw Materials
      if defined?(RawMaterial) && copy_table_data(prod_connection, 'raw_materials', RawMaterial)
        copied_tables << 'raw_materials'
      end
      
      # Restore original UAT connection
      ActiveRecord::Base.establish_connection(Rails.env)
      
      render json: {
        status: 'success',
        message: 'Data copied successfully from production',
        tables_copied: copied_tables,
        timestamp: Time.current
      }
      
    rescue => e
      # Restore connection on error
      ActiveRecord::Base.establish_connection(Rails.env) rescue nil
      
      render json: {
        status: 'error',
        message: e.message,
        timestamp: Time.current
      }, status: 500
    end
  end
  
  private
  
  def copy_table_data(prod_connection, table_name, model_class)
    return false unless prod_connection.table_exists?(table_name)
    
    # Get data from production
    prod_data = prod_connection.select_all("SELECT * FROM #{table_name}")
    
    return true if prod_data.rows.empty?
    
    # Clear UAT table
    model_class.delete_all
    
    # Copy data to UAT
    prod_data.each do |row|
      model_class.create!(row.except('created_at', 'updated_at'))
    end
    
    true
  rescue => e
    Rails.logger.error "Failed to copy #{table_name}: #{e.message}"
    false
  end
end