class UpdateColorsViewsVersion2 < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_colors(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                code VARCHAR,
                name VARCHAR,
                cost_of_color DOUBLE PRECISION
            ) AS $$
            BEGIN
                return query
                select
                        colors.id, colors.code, colors.name,
                        CASE
                            WHEN colors_location_prices.cost_of_color IS NOT NULL THEN colors_location_prices.cost_of_color
                            ELSE colors.cost_of_color
                        END AS cost_of_color
                from colors
                left join colors_location_prices on colors_location_prices.colors_id = colors.id and colors_location_prices.locations_id = location_id_param
                GROUP BY colors.id, colors_location_prices.cost_of_color
                ORDER BY colors.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_colors(integer)
        ))
    end
end
