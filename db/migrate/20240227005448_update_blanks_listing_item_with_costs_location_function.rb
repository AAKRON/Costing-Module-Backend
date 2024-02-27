class UpdateBlanksListingItemWithCostsLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_blanks_listing_item_with_costs(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                item_number INT,
                blank_number INT,
                cost NUMERIC,
                total_blank_cost_for_price NUMERIC,
                total_blank_cost_for_inventory NUMERIC
            ) AS $$
            BEGIN
                return query
                SELECT
                    blbi.id,
                    blbi.item_number,
                    blbi.blank_number,
                CAST(((bcv.cost * COALESCE(blbi.mult, 1))/(CASE WHEN COALESCE(blbi.div, 1) = 0 THEN 1 ELSE COALESCE(blbi.div, 1) END)) AS DECIMAL(10,5)) AS cost,
                CASE
                    WHEN bcv.type_number = 1
                    THEN
                        CAST(((bcv.total_blank_cost_for_price * COALESCE(blbi.mult, 1))/ COALESCE(blbi.div, 1)) AS DECIMAL(10,5))
                    ELSE 0
                    END
                AS total_blank_cost_for_price,
                CASE
                    WHEN bcv.type_number = 1
                    THEN
                        CAST(((bcv.total_blank_cost_for_inventory * COALESCE(blbi.mult, 1))/ COALESCE(blbi.div, 1)) AS DECIMAL(10,5))
                    ELSE 0
                    END
                AS total_blank_cost_for_inventory
                FROM blanks_listing_by_items AS blbi
                LEFT JOIN get_blanks(location_id_param) AS bcv ON bcv.id = blbi.blank_number;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
    end
end
