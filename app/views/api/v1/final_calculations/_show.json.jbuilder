# frozen_string_literal: true

raw_calculated = 0.0
cost_of_colorant_or_lacquer = 0.0

final_calculation_calculated = FinalCalculationDecorator.new(final_calculation)

# Safely fetch values
color_one_cost = final_calculation_calculated.color_one_cost.to_f
color_two_cost = final_calculation_calculated.color_two_cost.to_f

json.id final_calculation.id
json.blank_id final_calculation.blank_id
json.color_number final_calculation.color_number
json.color_description final_calculation.color_description
json.raw_material_id final_calculation.raw_material_id

json.colorant_one final_calculation.colorant_one
json.number_of_pieces_per_unit_one final_calculation.number_of_pieces_per_unit_one
json.percentage_of_colorant_one final_calculation.percentage_of_colorant_one

json.colorant_two final_calculation.colorant_two
json.number_of_pieces_per_unit_two final_calculation.number_of_pieces_per_unit_two || 1
json.percentage_of_colorant_two final_calculation.percentage_of_colorant_two || 0

json.raw_material_name final_calculation.raw_material.name
json.raw_material_cost final_calculation_calculated.raw_material_cost.to_f
json.raw_calculated final_calculation_calculated.raw_calculated.to_f

json.color_one_cost color_one_cost
json.color_two_cost color_two_cost

# -------- COLOR ONE COST --------
number_of_pieces_per_unit_one = final_calculation.number_of_pieces_per_unit_one.to_f.nonzero? || 1.0
percentage_of_colorant_one = final_calculation.percentage_of_colorant_one.to_f

final_color_one_cost =
  ((color_one_cost * percentage_of_colorant_one) / number_of_pieces_per_unit_one).round(5)

json.fina_color_one_cost final_color_one_cost

# -------- COLOR TWO COST --------
number_of_pieces_per_unit_two =
  final_calculation.number_of_pieces_per_unit_two.to_f.nonzero? || 1.0

percentage_of_colorant_two =
  final_calculation.percentage_of_colorant_two.to_f

final_color_two_cost =
  ((color_two_cost * percentage_of_colorant_two) / number_of_pieces_per_unit_two).round(5)

json.fina_color_two_cost final_color_two_cost

# -------- TOTAL COST --------
cost_of_colorant_or_lacquer =
  (final_color_one_cost + final_color_two_cost).round(5)

json.cost_of_colorant_or_lacquer cost_of_colorant_or_lacquer
json.total_cost (final_calculation_calculated.raw_calculated.to_f + cost_of_colorant_or_lacquer).round(5)

json.blank_final_calculations_view final_calculation_calculated.blank_final_calculations_view
json.blank_average_cost final_calculation_calculated.blank_average_cost

# -------- FORMATTED OUTPUT --------
json.number_of_pieces_per_unit_one format(
  "%.2f",
  number_of_pieces_per_unit_one
)

json.number_of_pieces_per_unit_two format(
  "%.2f",
  number_of_pieces_per_unit_two
)
