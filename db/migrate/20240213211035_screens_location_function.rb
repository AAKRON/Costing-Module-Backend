class ScreensLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_screens(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                screen_size VARCHAR,
                cost DOUBLE PRECISION
            ) AS $$
            BEGIN
                return query
                select
                        screens.id, screens.screen_size,
                        CASE
                            WHEN screens_location_prices.cost IS NOT NULL THEN screens_location_prices.cost
                            ELSE screens.cost
                        END AS cost
                from screens
                left join screens_location_prices on screens_location_prices.screens_id = screens.id and screens_location_prices.locations_id = location_id_param
                GROUP BY screens.id, screens_location_prices.cost
                ORDER BY screens.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_screens(integer)
        ))
    end
end
