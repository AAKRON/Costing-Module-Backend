class CreateAppConstantViews < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_app_constants(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                name VARCHAR,
                value VARCHAR
            ) AS $$
            BEGIN
                return query
                select
                        app_constants.id, app_constants.name,
                        CASE
                            WHEN app_constants_location_prices.value IS NOT NULL THEN app_constants_location_prices.value
                            ELSE app_constants.value
                        END AS value
                from app_constants
                left join app_constants_location_prices on app_constants_location_prices.app_constants_id = app_constants.id and app_constants_location_prices.locations_id = location_id_param
                GROUP BY app_constants.id, app_constants_location_prices.value
                ORDER BY app_constants.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_app_constants(integer)
        ))
    end
end
