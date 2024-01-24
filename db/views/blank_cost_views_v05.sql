CREATE OR REPLACE FUNCTION get_blanks(IN location_id_param INT)
RETURNS TABLE (
  id INT,
  blank_number INT,
  description VARCHAR,
  cost DOUBLE PRECISION,
  blank_type_id INT,
  type_number INT,
  blank_type VARCHAR,
  total_blank_cost_for_price DOUBLE PRECISION,
  total_blank_cost_for_inventory DOUBLE PRECISION
) AS $$
BEGIN
	return query
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
        (jl.wages_per_hour * bj.hour_per_piece * CAST(acpo.value AS numeric))
        ) AS cost_for_price,
        SUM(
        (jl.wages_per_hour * bj.hour_per_piece)
        +
        (jl.wages_per_hour * bj.hour_per_piece * CAST(acio.value AS numeric) )
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
    ON b.blank_type_id = bt.type_number

    -- left join job_location_prices on job_location_prices.job_listings_id = jl.id and job_location_prices.locations_id = location_id_param
    -- GROUP BY jl.id, s.screen_size, job_location_prices.wages_per_hour
    -- ORDER BY jl.id;
END;
$$ LANGUAGE plpgsql;
