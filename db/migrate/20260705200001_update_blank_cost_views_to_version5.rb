class UpdateBlankCostViewsToVersion5 < ActiveRecord::Migration[7.2]
  def up
    # Must drop dependents first; Scenic's plain DROP VIEW is blocked by Postgres
    execute "DROP VIEW IF EXISTS item_cost_views;"
    execute "DROP VIEW IF EXISTS item_with_blank_per_cost_views;"
    execute "DROP VIEW IF EXISTS blank_cost_views;"

    # blank_cost_views v05: COALESCE guards on app_constants so missing records
    # return 0 overhead instead of NULLing out the entire SUM.
    execute <<~SQL
      CREATE VIEW blank_cost_views AS
      Select
        DISTINCT ON (b.blank_number) b.id,
        b.blank_number,
        b.description,
        CAST(b.cost AS DECIMAL(10,5)) AS cost,
        bt.id as blank_type_id,
        bt.type_number,
        bt.description AS blank_type,
        COALESCE(
          CAST(
            (bc.cost_for_price + COALESCE(bac.average_cost_of_blank, 0)
          ) AS DECIMAL(10,5)
        ), 0) AS total_blank_cost_for_price,
        COALESCE(
          CAST(
            (bc.cost_for_inventory + COALESCE(bac.average_cost_of_blank, 0)
          ) AS DECIMAL(10,5)
        ), 0) AS total_blank_cost_for_inventory
      FROM (
        SELECT
          bj.blank_id,
          SUM(
            (jl.wages_per_hour * bj.hour_per_piece)
            +
            (jl.wages_per_hour * bj.hour_per_piece * COALESCE(CAST(acpo.value AS numeric), 0))
          ) AS cost_for_price,
          SUM(
            (jl.wages_per_hour * bj.hour_per_piece)
            +
            (jl.wages_per_hour * bj.hour_per_piece * COALESCE(CAST(acio.value AS numeric), 0))
          ) AS cost_for_inventory
        FROM "blank_jobs" bj
        LEFT JOIN job_listings jl ON jl.id=bj.job_listing_id
        LEFT JOIN app_constants acpo ON acpo.name = 'price_overhead_percentage'
        LEFT JOIN app_constants acio ON acio.name = 'inventory_overhead_percentage'
        GROUP BY  bj.blank_id
      ) AS bc
      LEFT JOIN blank_average_costs AS bac ON bac.blank_id= bc.blank_id
      RIGHT JOIN blanks b ON b.id=bc.blank_id
      LEFT JOIN blank_types bt
      ON b.blank_type_id = bt.type_number;
    SQL

    execute <<~SQL
      CREATE VIEW item_with_blank_per_cost_views AS
      SELECT
        bliwc.id, bliwc.item_number, bliwc.blank_number,
        CAST(((bcv.cost * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,5)) AS cost,
        CASE WHEN bcv.type_number = 1 THEN CAST(((bcv.total_blank_cost_for_price * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,5)) ELSE 0 END AS total_blank_cost_for_price,
        CASE WHEN bcv.type_number = 1 THEN CAST(((bcv.total_blank_cost_for_inventory * COALESCE(blbi.mult, 1)) / CASE WHEN COALESCE(blbi.div, 0) = 0 THEN 1 ELSE blbi.div END) AS DECIMAL(10,5)) ELSE 0 END AS total_blank_cost_for_inventory
      FROM blanks_listing_item_with_costs AS bliwc
      LEFT JOIN blank_cost_views AS bcv ON bcv.id = bliwc.blank_number
      LEFT JOIN blanks_listing_by_items AS blbi ON blbi.item_number = bliwc.item_number AND blbi.blank_number = bliwc.blank_number;
    SQL

    execute <<~SQL
      CREATE VIEW item_cost_views AS
      SELECT i.id, i.item_number, i.description, it.description AS type_description, i.item_type_id,
        b.name AS box_name, i.number_of_pcs_per_box,
        CAST(i.ink_cost AS DECIMAL(10,5)) AS ink_cost,
        CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5)) AS box_cost,
        CAST((
          COALESCE(ibc.item_blank_cost_for_price, 0)
          + COALESCE(ijcws.cost_for_price, 0)
          + CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5))
          + COALESCE(ijcws.screen_cost, 0)
          + i.ink_cost
        ) AS DECIMAL(10,5)) AS total_price_cost,
        CAST((
          COALESCE(ibc.item_blank_cost_for_inventory, 0)
          + COALESCE(ijcws.cost_for_inventory, 0)
          + CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5))
          + COALESCE(ijcws.screen_cost, 0)
          + i.ink_cost
        ) AS DECIMAL(10,5)) AS total_inventory_cost
      FROM items i
      LEFT JOIN boxes b ON i.box_id = b.id
      LEFT JOIN (
        SELECT iwbpcv.item_number,
          SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_price)     AS item_blank_cost_for_price,
          SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_inventory) AS item_blank_cost_for_inventory
        FROM item_with_blank_per_cost_views AS iwbpcv
        GROUP BY iwbpcv.item_number
      ) AS ibc ON ibc.item_number = i.id
      LEFT JOIN (
        SELECT ij.item_id,
          SUM(CAST(
            CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5))
            + CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5))
              * COALESCE(CAST(acpo.value AS numeric), 0)
          AS DECIMAL(10,5))) AS cost_for_price,
          SUM(CAST(
            CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5))
            + CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5))
              * COALESCE(CAST(acio.value AS numeric), 0)
          AS DECIMAL(10,5))) AS cost_for_inventory,
          SUM(COALESCE(s.cost, 0)) AS screen_cost
        FROM item_jobs AS ij
        LEFT JOIN job_listings jl ON jl.id = ij.job_listing_id
        LEFT JOIN screens s ON s.id = jl.screen_id
        LEFT JOIN app_constants acpo ON acpo.name = 'price_overhead_percentage'
        LEFT JOIN app_constants acio ON acio.name = 'inventory_overhead_percentage'
        GROUP BY ij.item_id
      ) AS ijcws ON ijcws.item_id = i.id
      LEFT JOIN item_types it ON it.type_number = i.item_type_id;
    SQL
  end

  def down; end
end
