CREATE OR REPLACE FUNCTION public.get_blanks(
	location_id_param integer)
    RETURNS TABLE(id integer, blank_number integer, description character varying, cost numeric, blank_type_id integer, type_number integer, blank_type character varying, total_blank_cost_for_price numeric, total_blank_cost_for_inventory numeric)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
   r record;
BEGIN
	FOR r IN
		Select
		DISTINCT ON (b.blank_number) b.id,
		b.blank_number,
		b.description,
		b.cost,
		bt.id as blank_type_id,
		bt.type_number,
		bt.description AS blank_type,
		bc.cost_for_price,
		bc.cost_for_inventory,
		COALESCE(bac.average_cost_of_blank, 0)  AS  average_cost_of_blank,
		blanks_location_prices.cost as blanks_location_prices_cost
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
			LEFT JOIN get_jobs(location_id_param) jl ON jl.id=bj.job_listing_id
			LEFT JOIN app_constants acpo ON acpo.name = 'price_overhead_percentage'
			LEFT JOIN app_constants acio ON acio.name = 'inventory_overhead_percentage'
			GROUP BY  bj.blank_id
		) AS bc
		LEFT JOIN blank_average_costs AS bac ON bac.blank_id= bc.blank_id
		RIGHT JOIN blanks b ON b.id=bc.blank_id
		LEFT JOIN blank_types bt ON b.blank_type_id = bt.type_number
		LEFT JOIN blanks_location_prices on blanks_location_prices.blanks_id = b.id and blanks_location_prices.locations_id = location_id_param
	LOOP
		id = r.id;
		blank_number = r.blank_number;
		description = r.description;
		cost = CASE
                WHEN r.blanks_location_prices_cost IS NOT NULL THEN r.blanks_location_prices_cost
                ELSE r.cost
            END;
		blank_type_id = r.blank_type_id;
		type_number = r.type_number;
		blank_type = r.blank_type;

		total_blank_cost_for_price = COALESCE(CAST((r.cost_for_price + r.average_cost_of_blank) AS DECIMAL(10,5)), 0);
		total_blank_cost_for_inventory = COALESCE(CAST((r.cost_for_inventory + r.average_cost_of_blank) AS DECIMAL(10,5)), 0);
		RETURN NEXT;
	END LOOP;

	RETURN NEXT;
END;
$BODY$;