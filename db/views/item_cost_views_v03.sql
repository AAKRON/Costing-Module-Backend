select
  i.id,
  i.item_number,
  i.description,
  it.description as type_description,
  i.item_type_id,
  b.name as box_name,
  i.number_of_pcs_per_box,
	CAST(i.ink_cost AS DECIMAL(10,4)) AS ink_cost,
  CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,4)) AS box_cost,
  (COALESCE(ibc.item_blank_cost_for_price, 0)
   +
   COALESCE(ijcws.cost_for_price, 0)
   +
   CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN  i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,4))
   +
   COALESCE(ijcws.screen_cost, 0)
   +
   i.ink_cost
  ) AS total_price_cost,
  (COALESCE(ibc.item_blank_cost_for_inventory, 0)
   +
   COALESCE(ijcws.cost_for_inventory, 0)
   +
   CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN  i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,4))
   +
   COALESCE(ijcws.screen_cost, 0)
   +
   i.ink_cost
  ) AS total_inventory_cost
FROM items i
LEFT JOIN boxes b
ON i.box_id = b.id
LEFT JOIN (
        SELECT
          iwbpcv.item_number,
          SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_price) AS item_blank_cost_for_price,
          SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_inventory) AS item_blank_cost_for_inventory
        FROM item_with_blank_per_cost_views AS iwbpcv
        GROUP BY iwbpcv.item_number
      ) AS ibc
ON ibc.item_number = i.id
LEFT JOIN (
      SELECT
        ij.item_id,
        CAST(
          SUM(
            (jl.wages_per_hour * ij.hour_per_piece)
            +
            (jl.wages_per_hour * ij.hour_per_piece * CAST(acpo.value AS numeric))
          )
        AS DECIMAL(10,4)) AS cost_for_price,
        CAST(
          SUM(
            (jl.wages_per_hour * ij.hour_per_piece)
            +
            (jl.wages_per_hour * ij.hour_per_piece * CAST(acio.value AS numeric) )
          )
        AS DECIMAL(10,4)) AS cost_for_inventory,
        SUM(COALESCE(s.cost, 0)) as screen_cost
      FROM "item_jobs" AS ij
      LEFT JOIN job_listings jl ON jl.id=ij.job_listing_id
      LEFT JOIN screens s ON s.id = jl.screen_id
      LEFT JOIN app_constants acpo ON acpo.name = 'price_overhead_percentage'
      LEFT JOIN app_constants acio ON acio.name = 'inventory_overhead_percentage'
      GROUP BY  ij.item_id
    ) AS ijcws
ON ijcws.item_id = i.id
LEFT JOIN item_types it
ON it.type_number = i.item_type_id
