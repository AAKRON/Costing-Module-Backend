color_one_cost = 0.0
color_two_cost = 0.0
raw_calculated = 0.0
cost_of_colorant_or_lacquer = 0.0

json.id final_calculation.id
json.blank_id final_calculation.blank_id
json.color_number final_calculation.color_number
json.color_description final_calculation.color_description
json.raw_material_id final_calculation.raw_material_id
json.colorant_one final_calculation.colorant_one
json.number_of_pieces_per_unit_one final_calculation.number_of_pieces_per_unit_one
json.percentage_of_colorant_one final_calculation.percentage_of_colorant_one
json.colorant_two final_calculation.colorant_two
json.number_of_pieces_per_unit_two final_calculation.number_of_pieces_per_unit_two
json.percentage_of_colorant_two final_calculation.percentage_of_colorant_two
json.raw_material_name final_calculation.raw_material.name
json.raw_material_cost final_calculation.raw_material.cost
raw_calculated  = (final_calculation.raw_material.cost/final_calculation.number_of_pieces_per_unit_one).round(5)
json.raw_calculated raw_calculated

if final_calculation.colorant_one != ''
  color_one_cost = Color.where(name: final_calculation.colorant_one)[0].try(:cost_of_color) || 0.0
end
json.color_one_cost color_one_cost

if final_calculation.colorant_two != ''
  color_two_cost = Color.where(name: final_calculation.colorant_two)[0].try(:cost_of_color) || 0.0
end
json.color_two_cost color_two_cost

final_color_one_cost = ((color_one_cost * final_calculation.percentage_of_colorant_one) / final_calculation.number_of_pieces_per_unit_one).round(5)
json.fina_color_one_cost final_color_one_cost

final_color_two_cost = ((color_two_cost*final_calculation.percentage_of_colorant_two)/final_calculation.number_of_pieces_per_unit_two).round(5)
json.fina_color_two_cost final_color_two_cost

cost_of_colorant_or_lacquer = (final_color_one_cost + final_color_two_cost).round(5)
json.cost_of_colorant_or_lacquer cost_of_colorant_or_lacquer

json.total_cost (raw_calculated+cost_of_colorant_or_lacquer).round(5)

json.blank_final_calculations_view BlankFinalCalculationsView.where(blank_number: final_calculation.blank_id)

json.blank_average_cost BlankAverageCost.find_by_blank_id(final_calculation.blank_id).try(:average_cost_of_blank) || 0.0
