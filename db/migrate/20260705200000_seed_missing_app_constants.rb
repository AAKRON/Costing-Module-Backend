class SeedMissingAppConstants < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      INSERT INTO app_constants (name, value, created_at, updated_at)
      SELECT 'price_overhead_percentage', '4', NOW(), NOW()
      WHERE NOT EXISTS (
        SELECT 1 FROM app_constants WHERE name = 'price_overhead_percentage'
      );
    SQL
    execute <<~SQL
      INSERT INTO app_constants (name, value, created_at, updated_at)
      SELECT 'inventory_overhead_percentage', '0.9569', NOW(), NOW()
      WHERE NOT EXISTS (
        SELECT 1 FROM app_constants WHERE name = 'inventory_overhead_percentage'
      );
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM app_constants
      WHERE name IN ('price_overhead_percentage', 'inventory_overhead_percentage');
    SQL
  end
end
