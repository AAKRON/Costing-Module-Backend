SELECT
  bliwc.id,
  bliwc.item_number,
  bliwc.blank_number,
  CAST(((bcv.cost * COALESCE(blbi.mult, 1))/COALESCE(blbi.div, 1)) AS DECIMAL(10,4)) AS cost,
  CASE
    WHEN bcv.type_number = 1
      THEN
        CAST(((bcv.total_blank_cost_for_price * COALESCE(blbi.mult, 1))/ COALESCE(blbi.div, 1)) AS DECIMAL(10,4))
      ELSE 0
    END
  AS total_blank_cost_for_price,
  CASE
    WHEN bcv.type_number = 1
      THEN
        CAST(((bcv.total_blank_cost_for_inventory * COALESCE(blbi.mult, 1))/ COALESCE(blbi.div, 1)) AS DECIMAL(10,4))
      ELSE 0
    END
  AS total_blank_cost_for_inventory
FROM blanks_listing_item_with_costs AS bliwc
LEFT JOIN blank_cost_views AS bcv
ON bcv.id = bliwc.blank_number
LEFT JOIN blanks_listing_by_items AS blbi
ON blbi.item_number = bliwc.item_number AND blbi.blank_number = bliwc.blank_number
