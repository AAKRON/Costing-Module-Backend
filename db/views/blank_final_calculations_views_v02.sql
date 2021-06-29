SELECT fc.id,
  fc.blank_id AS blank_number,
  b.description AS blank_name,
  rm.name AS raw_material,
  fc.color_description,
  (COALESCE(rm.cost, 0) / number_of_pieces_per_unit_one) AS raw_calculated,
  ((COALESCE(c1.cost_of_color,0) * percentage_of_colorant_one) / number_of_pieces_per_unit_one) + ((COALESCE(c2.cost_of_color, 0) * percentage_of_colorant_two) / number_of_pieces_per_unit_two) AS cost_of_colorant_or_lacquer,
  ((COALESCE(rm.cost, 0) / number_of_pieces_per_unit_one)) + (((COALESCE(c1.cost_of_color,0) * percentage_of_colorant_one) / number_of_pieces_per_unit_one) + ((COALESCE(c2.cost_of_color, 0) * percentage_of_colorant_two) / number_of_pieces_per_unit_two)) AS total,
  bac.average_cost_of_blank AS ave_cost
FROM final_calculations fc
LEFT JOIN colors c1
ON c1.name = fc.colorant_one
LEFT JOIN colors c2
ON c2.name = fc.colorant_two
LEFT JOIN raw_materials rm
ON rm.id = fc.raw_material_id
LEFT JOIN blanks b
ON b.id = fc.blank_id
LEFT JOIN blank_average_costs bac
ON bac.blank_id = fc.blank_id
