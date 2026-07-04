class FixViewsDivisionByZero < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      CREATE OR REPLACE VIEW item_with_blank_per_cost_views AS
      SELECT
        bliwc.id,
        bliwc.item_number,
        bliwc.blank_number,
        CAST(((bcv.cost * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,4)) AS cost,
        CASE
          WHEN bcv.type_number = 1
            THEN CAST(((bcv.total_blank_cost_for_price * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,4))
          ELSE 0
        END AS total_blank_cost_for_price,
        CASE
          WHEN bcv.type_number = 1
            THEN CAST(((bcv.total_blank_cost_for_inventory * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,4))
          ELSE 0
        END AS total_blank_cost_for_inventory
      FROM blanks_listing_item_with_costs AS bliwc
      LEFT JOIN blank_cost_views AS bcv ON bcv.id = bliwc.blank_number
      LEFT JOIN blanks_listing_by_items AS blbi
        ON blbi.item_number = bliwc.item_number AND blbi.blank_number = bliwc.blank_number;
    SQL

    execute <<~SQL
      CREATE OR REPLACE VIEW blank_final_calculations_views AS
      SELECT fc.id,
        fc.blank_id AS blank_number,
        b.description AS blank_name,
        rm.name AS raw_material,
        fc.color_description,
        CAST((COALESCE(rm.cost, 0) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_one END) AS DECIMAL(10,5)) AS raw_calculated,
        CAST(
          CAST(((COALESCE(c1.cost_of_color,0) * COALESCE(fc.percentage_of_colorant_one, 0)) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_one END) AS DECIMAL(10,5))
          + CAST(((COALESCE(c2.cost_of_color, 0) * COALESCE(fc.percentage_of_colorant_two, 0)) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_two, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_two END) AS DECIMAL(10,5))
        AS DECIMAL(10,5)) AS cost_of_colorant_or_lacquer,
        CAST(
          CAST((COALESCE(rm.cost, 0) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_one END) AS DECIMAL(10,5))
          + CAST(
              ((COALESCE(c1.cost_of_color, 0) * COALESCE(fc.percentage_of_colorant_one, 0)) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_one END)
              + ((COALESCE(c2.cost_of_color, 0) * COALESCE(fc.percentage_of_colorant_two, 0)) / CASE WHEN COALESCE(fc.number_of_pieces_per_unit_two, 0) = 0 THEN 1 ELSE fc.number_of_pieces_per_unit_two END)
            AS DECIMAL(10,5))
        AS DECIMAL(10,5)) AS total,
        bac.average_cost_of_blank AS ave_cost
      FROM final_calculations fc
      LEFT JOIN colors c1 ON c1.name = fc.colorant_one
      LEFT JOIN colors c2 ON c2.name = fc.colorant_two
      LEFT JOIN raw_materials rm ON rm.id = fc.raw_material_id
      LEFT JOIN blanks b ON b.id = fc.blank_id
      LEFT JOIN blank_average_costs bac ON bac.blank_id = fc.blank_id;
    SQL
  end

  def down
    # no rollback — fixing a data-safety bug
  end
end
