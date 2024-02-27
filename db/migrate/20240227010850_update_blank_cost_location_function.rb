class UpdateBlankCostLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION public.get_blanks(
                location_id_param integer)
                RETURNS TABLE(
                    id integer,
                    blank_number integer,
                    description character varying,
                    cost numeric(10,5),
                    blank_type_id integer,
                    type_number integer,
                    blank_type character varying,
                    total_blank_cost_for_price numeric(10,5),
                    total_blank_cost_for_inventory numeric(10,5)
                )
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
                    CASE
                        WHEN blanks_location_prices.cost IS NOT NULL THEN blanks_location_prices.cost
                        ELSE b.cost
                    END AS blanks_location_prices_cost
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
                        LEFT JOIN get_app_constants(location_id_param) acpo ON acpo.name = 'price_overhead_percentage'
                        LEFT JOIN get_app_constants(location_id_param) acio ON acio.name = 'inventory_overhead_percentage'
                        GROUP BY  bj.blank_id
                    ) AS bc
                    LEFT JOIN get_blank_average_costs(location_id_param) AS bac ON bac.blank_id= bc.blank_id
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
        ))
    end

    def down
    end
end
