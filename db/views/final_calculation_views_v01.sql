SELECT fc.id,
  fc.blank_id,
  rm.name AS raw_material_name,
  fc.color_description,
  rm.cost AS raw_material_cost,
  c1.cost_of_color AS cost_of_color_one,
  c2.cost_of_color AS cost_of_color_two,
  fc.percentage_of_colorant_one,
  fc.percentage_of_colorant_two,
  fc.number_of_pieces_per_unit_one,
  fc.number_of_pieces_per_unit_two
FROM final_calculations fc
LEFT JOIN colors c1
ON c1.name = fc.colorant_one
LEFT JOIN colors c2
ON c2.name = fc.colorant_two
LEFT JOIN raw_materials rm
ON rm.id = fc.raw_material_id
