class FinalCalculationLocationFunction < ActiveRecord::Migration[6.1]
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_final_calculations(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                blank_id INT,
                raw_material_name VARCHAR,
                color_description VARCHAR,
                raw_material_cost DOUBLE PRECISION,
                cost_of_color_one DOUBLE PRECISION,
                cost_of_color_two DOUBLE PRECISION,
                percentage_of_colorant_one DOUBLE PRECISION,
                percentage_of_colorant_two DOUBLE PRECISION,
                number_of_pieces_per_unit_one INT,
                number_of_pieces_per_unit_two INT
            ) AS $$
            BEGIN
                return query
                SELECT fc.id,
                fc.blank_id,
                rm.name AS raw_material_name,
                fc.color_description,
                rm.cost AS raw_material_cost,
                COALESCE(c1.cost_of_color,0) AS cost_of_color_one,
                COALESCE(c2.cost_of_color,0) AS cost_of_color_two,
                COALESCE(fc.percentage_of_colorant_one, 0) AS percentage_of_colorant_one,
                COALESCE(fc.percentage_of_colorant_two, 0) AS percentage_of_colorant_two,
                fc.number_of_pieces_per_unit_one,
                fc.number_of_pieces_per_unit_two
                FROM final_calculations fc
                LEFT JOIN get_colors(location_id_param) c1 ON c1.name = fc.colorant_one
                LEFT JOIN get_colors(location_id_param) c2 ON c2.name = fc.colorant_two
                LEFT JOIN get_raw_materials(location_id_param) rm ON rm.id = fc.raw_material_id;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_final_calculations(integer)
        ))
    end
end
