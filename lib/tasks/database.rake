# lib/tasks/database.rake

namespace :db do
    desc "Backup and restore PostgreSQL database"
    task backup: :environment do
        max_db_year = DatabaseYear.order('year DESC').first.year

      puts "Backing up PostgreSQL database..."
      system("pg_dump -U #{ENV['PGUSER']} -d #{ENV['PG_DB_DEV']} > '#{Rails.root}/db/backup.sql'")
      puts "Backup completed."

      puts "Creating PostgreSQL database..."
      system("createdb -U #{ENV['PGUSER']} #{ENV['PG_DB_DEV']}_#{max_db_year}")
      puts "Database created."

      puts "Restoring PostgreSQL database..."
      system("psql -U #{ENV['PGUSER']} -d #{ENV['PG_DB_DEV']}_#{max_db_year} < '#{Rails.root}/db/backup.sql'")
      puts "Restore completed."
    end
end