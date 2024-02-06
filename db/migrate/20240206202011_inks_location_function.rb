class InksLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_inks(IN location_id_param INT)
            RETURNS TABLE (
                id BIGINT,
                name VARCHAR,
                ink_cost NUMERIC
            ) AS $$
            BEGIN
                return query
                select
                        inks.id, inks.name,
                        CASE
                            WHEN inks_location_prices.ink_cost IS NOT NULL THEN inks_location_prices.ink_cost
                            ELSE inks.ink_cost
                        END AS ink_cost
                from inks
                left join inks_location_prices on inks_location_prices.inks_id = inks.id and inks_location_prices.locations_id = location_id_param
                GROUP BY inks.id, inks_location_prices.ink_cost
                ORDER BY inks.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_inks(integer)
        ))
    end
end
