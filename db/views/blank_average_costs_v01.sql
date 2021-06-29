SELECT blank_id,
  CAST(
    AVG(
      (
        (COALESCE(raw_material_cost, 0) / number_of_pieces_per_unit_one)
        +
        ((COALESCE(cost_of_color_one, 0) * percentage_of_colorant_one) / number_of_pieces_per_unit_one)
        +
        ((COALESCE(cost_of_color_two, 0) * percentage_of_colorant_two) / number_of_pieces_per_unit_two)
      )
    ) AS DECIMAL(10,5)) AS average_cost_of_blank
FROM final_calculation_views
GROUP BY blank_id
