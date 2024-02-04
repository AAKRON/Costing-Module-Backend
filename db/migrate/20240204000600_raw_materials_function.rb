class RawMaterialsFunction < ActiveRecord::Migration[6.1]
  def change
    def up
        connection.execute(%q(
            CREATE OR REPLACE FUNCTION get_raw_materials(IN location_id_param INT)
            RETURNS TABLE (
                id INT,
                name VARCHAR,
                raw_material_type VARCHAR,
                vendor VARCHAR,
                unit VARCHAR,
                color VARCHAR,
                cost DOUBLE PRECISION
            ) AS $$
            BEGIN
                return query
                SELECT DISTINCT ON(raw_materials.name) raw_materials.id, raw_materials.name, t4.name AS raw_material_type, t3.name AS vendor, t5.name AS unit, t2.name AS color,
                CASE
                    WHEN raw_materials_location_prices.cost IS NOT NULL THEN raw_materials_location_prices.cost
                    ELSE raw_materials.cost
                END AS cost
                FROM raw_materials
                INNER JOIN colors t2 ON raw_materials.color_id = t2.id
                INNER JOIN vendors t3 ON raw_materials.vendor_id = t3.id
                INNER JOIN rawmaterialtypes t4 ON raw_materials.rawmaterialtype_id = t4.id
                INNER JOIN units_of_measures t5  ON raw_materials.units_of_measure_id = t5.id
                LEFT JOIN raw_materials_location_prices on raw_materials_location_prices.raw_materials_id = raw_materials.id and raw_materials_location_prices.locations_id = location_id_param;
            END;
            $$ LANGUAGE plpgsql;
        ))
    end

    def down
        connection.execute(%q(
            drop function get_raw_materials(integer)
        ))
    end
  end
end
