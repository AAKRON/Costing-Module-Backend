class UpdateItemCostLocationFunctionV3 < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_item_costs(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                item_number INT,
                description VARCHAR,
                type_description VARCHAR,
                item_type_id INT,
                box_name VARCHAR,
                number_of_pcs_per_box INT,
                ink_cost NUMERIC,
                box_cost NUMERIC,
                secondary_box_cost NUMERIC,
                total_price_cost NUMERIC,
                total_inventory_cost NUMERIC
            ) AS $$
            BEGIN
                return query
                SELECT
                i.id,
                i.item_number,
                i.description,
                it.description as type_description,
                i.item_type_id,
                b.name as box_name,
                i.number_of_pcs_per_box,
                CAST(COALESCE(inks.ink_cost, i.ink_cost) AS DECIMAL(10,5)) AS ink_cost,
                CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5)) AS box_cost,
                CAST((COALESCE(secondary_box.cost_per_box, 0) / CASE WHEN  COALESCE(i.number_of_pcs_per_secondary_box, 0) = 0 THEN 1 ELSE i.number_of_pcs_per_secondary_box END) AS DECIMAL(10,5)) AS secondary_box_cost,
                CAST((COALESCE(ibc.item_blank_cost_for_price, 0)
                    +
                    COALESCE(ijcws.cost_for_price, 0)
                    +
                    CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN  i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5))
                    +
                    CAST((COALESCE(secondary_box.cost_per_box, 0) / CASE WHEN  COALESCE(i.number_of_pcs_per_secondary_box, 0) = 0 THEN 1 ELSE i.number_of_pcs_per_secondary_box END) AS DECIMAL(10,5))
                    +
                    COALESCE(ijcws.screen_cost, 0)
                    +
                    COALESCE(inks.ink_cost, i.ink_cost)
                ) AS DECIMAL(10,5)) AS total_price_cost,
                CAST(COALESCE(COALESCE(ibc.item_blank_cost_for_inventory, 0)
                    +
                    COALESCE(ijcws.cost_for_inventory, 0)
                    +
                    CAST((COALESCE(b.cost_per_box, 0) / CASE WHEN  i.number_of_pcs_per_box = 0 THEN 1 ELSE i.number_of_pcs_per_box END) AS DECIMAL(10,5))
                    +
                    CAST((COALESCE(secondary_box.cost_per_box, 0) / CASE WHEN  COALESCE(i.number_of_pcs_per_secondary_box, 0) = 0 THEN 1 ELSE i.number_of_pcs_per_secondary_box END) AS DECIMAL(10,5))
                    +
                    COALESCE(ijcws.screen_cost, 0)
                    +
                    COALESCE(inks.ink_cost, i.ink_cost)
                , 0) AS DECIMAL(10,5)) AS total_inventory_cost
                FROM items i
                LEFT JOIN get_boxes(location_id_param) AS b ON i.box_id = b.id
                LEFT JOIN get_boxes(location_id_param) AS secondary_box ON i.secondary_box_id = secondary_box.id
                LEFT JOIN get_inks(location_id_param) AS inks ON i.ink_id = inks.id
                LEFT JOIN (
                    SELECT
                        iwbpcv.item_number,
                        SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_price) AS item_blank_cost_for_price,
                        SUM(iwbpcv.cost + iwbpcv.total_blank_cost_for_inventory) AS item_blank_cost_for_inventory
                    FROM get_blanks_listing_item_with_costs(location_id_param) AS iwbpcv
                    GROUP BY iwbpcv.item_number
                ) AS ibc ON ibc.item_number = i.id
                LEFT JOIN (
                    SELECT
                        ij.item_id,
                        SUM(CAST(
                            (CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5)))
                            +
                            (CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5)) * CAST(acpo.value AS numeric))
                        AS DECIMAL(10,5))) AS cost_for_price,
                        SUM(CAST(
                            (CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5)))
                            +
                            (CAST((jl.wages_per_hour * CAST(ij.hour_per_piece AS DECIMAL(10,5))) AS DECIMAL(10,5)) * CAST(acio.value AS numeric) )
                        AS DECIMAL(10,5))) AS cost_for_inventory,
                        SUM(COALESCE(s.cost, 0)) as screen_cost
                    FROM "item_jobs" AS ij
                    LEFT JOIN get_jobs(location_id_param) AS jl ON jl.id=ij.job_listing_id
                    LEFT JOIN get_screens(location_id_param) AS s ON s.id = jl.screen_id
                    LEFT JOIN get_app_constants(location_id_param) AS acpo ON acpo.name = 'price_overhead_percentage'
                    LEFT JOIN get_app_constants(location_id_param) AS acio ON acio.name = 'inventory_overhead_percentage'
                    GROUP BY  ij.item_id
                ) AS ijcws ON ijcws.item_id = i.id
                LEFT JOIN item_types it ON it.type_number = i.item_type_id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
    end
end
