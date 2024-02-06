class BoxesLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_boxes(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                name VARCHAR,
                cost_per_box NUMERIC
            ) AS $$
            BEGIN
                return query
                select
                        boxes.id, boxes.name,
                        CASE
                            WHEN boxes_location_prices.cost_per_box IS NOT NULL THEN boxes_location_prices.cost_per_box
                            ELSE boxes.cost_per_box
                        END AS cost_per_box
                from boxes
                left join boxes_location_prices on boxes_location_prices.boxes_id = boxes.id and boxes_location_prices.locations_id = location_id_param
                GROUP BY boxes.id, boxes_location_prices.cost_per_box
                ORDER BY boxes.id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_boxes(integer)
        ))
    end
end
