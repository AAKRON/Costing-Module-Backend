SELECT blank_id,
  CAST(
    AVG(
      (
        (COALESCE(raw_material_cost, 0) / CASE WHEN COALESCE(number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE number_of_pieces_per_unit_one END)
        +
        ((COALESCE(cost_of_color_one, 0) * COALESCE(percentage_of_colorant_one,0)) / CASE WHEN COALESCE(number_of_pieces_per_unit_one, 0) = 0 THEN 1 ELSE number_of_pieces_per_unit_one END)
        +
        ((COALESCE(cost_of_color_two, 0) * COALESCE(percentage_of_colorant_two,0)) / CASE WHEN COALESCE(number_of_pieces_per_unit_two, 0) = 0 THEN 1 ELSE number_of_pieces_per_unit_two END)
      )
    ) AS DECIMAL(10,5)) AS average_cost_of_blank
FROM final_calculation_views
GROUP BY blank_id
