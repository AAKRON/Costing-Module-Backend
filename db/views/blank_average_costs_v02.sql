SELECT blank_id,
  CAST(
    AVG(
      (
        (COALESCE(raw_material_cost, 0) / COALESCE(number_of_pieces_per_unit_one, 1))
        +
        ((COALESCE(cost_of_color_one, 0) * COALESCE(percentage_of_colorant_one,0)) / COALESCE(number_of_pieces_per_unit_one, 1))
        +
        ((COALESCE(cost_of_color_two, 0) * COALESCE(percentage_of_colorant_two,0)) / COALESCE(number_of_pieces_per_unit_two, 1))
      )
    ) AS DECIMAL(10,5)) AS average_cost_of_blank
FROM final_calculation_views
GROUP BY blank_id
