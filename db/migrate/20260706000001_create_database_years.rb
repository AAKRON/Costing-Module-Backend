# frozen_string_literal: true
class CreateDatabaseYears < ActiveRecord::Migration[7.2]
  def up
    create_table :database_years do |t|
      t.integer :year,   null: false
      t.boolean :frozen, null: false, default: false
      t.timestamps
    end
    add_index :database_years, :year, unique: true

    # Seed all known years as active
    (2019..2026).each do |y|
      execute "INSERT INTO database_years (year, frozen, created_at, updated_at) " \
              "VALUES (#{y}, false, NOW(), NOW())"
    end
  end

  def down
    drop_table :database_years
  end
end
