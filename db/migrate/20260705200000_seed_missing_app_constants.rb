class SeedMissingAppConstants < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      INSERT INTO app_constants (name, value, created_at, updated_at)
      VALUES
        ('price_overhead_percentage',    '4',      NOW(), NOW()),
        ('inventory_overhead_percentage', '0.9569', NOW(), NOW())
      ON CONFLICT (name) DO NOTHING;
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM app_constants
      WHERE name IN ('price_overhead_percentage', 'inventory_overhead_percentage');
    SQL
  end
end
