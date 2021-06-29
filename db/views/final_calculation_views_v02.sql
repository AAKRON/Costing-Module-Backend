SELECT fc.id,
  fc.blank_id,
  rm.name AS raw_material_name,
  fc.color_description,
  rm.cost AS raw_material_cost,
  COALESCE(c1.cost_of_color,0) AS cost_of_color_one,
  COALESCE(c2.cost_of_color,0) AS cost_of_color_two,
  COALESCE(fc.percentage_of_colorant_one, 0) AS percentage_of_colorant_one,
  COALESCE(fc.percentage_of_colorant_two, 0) AS percentage_of_colorant_two,
  COALESCE(fc.number_of_pieces_per_unit_one, 1) AS number_of_pieces_per_unit_one,
  COALESCE(fc.number_of_pieces_per_unit_two,1) AS number_of_pieces_per_unit_two
FROM final_calculations fc
LEFT JOIN colors c1
ON c1.name = fc.colorant_one
LEFT JOIN colors c2
ON c2.name = fc.colorant_two
LEFT JOIN raw_materials rm
ON rm.id = fc.raw_material_id
