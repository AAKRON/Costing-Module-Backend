class CreateDatabaseYears < ActiveRecord::Migration[6.1]
  def change
    create_table :database_years do |t|
      t.string "year"
      t.timestamps
    end
  end
end
