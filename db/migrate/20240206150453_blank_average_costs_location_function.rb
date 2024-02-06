class BlankAverageCostsLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_blank_average_costs(IN location_id_param INT)
            RETURNS TABLE (
                blank_id INT,
                average_cost_of_blank numeric(10,5)
            ) AS $$
            BEGIN
                return query
                SELECT fc.blank_id,
                CAST(
                    AVG(
                    (
                        (COALESCE(raw_material_cost, 0) / COALESCE(CASE WHEN number_of_pieces_per_unit_one = 0 THEN 1 ELSE number_of_pieces_per_unit_one END, 1))
                        +
                        ((COALESCE(cost_of_color_one, 0) * COALESCE(percentage_of_colorant_one,0)) / COALESCE(CASE WHEN number_of_pieces_per_unit_one = 0 THEN 1 ELSE number_of_pieces_per_unit_one END, 1))
                        +
                        ((COALESCE(cost_of_color_two, 0) * COALESCE(percentage_of_colorant_two,0)) / COALESCE(CASE WHEN number_of_pieces_per_unit_two = 0 THEN 1 ELSE number_of_pieces_per_unit_two END,1))
                    )
                    ) AS DECIMAL(10,5)) AS average_cost_of_blank
                FROM get_final_calculations(location_id_param)  fc
                GROUP BY fc.blank_id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_blank_average_costs(integer)
        ))
    end
end
