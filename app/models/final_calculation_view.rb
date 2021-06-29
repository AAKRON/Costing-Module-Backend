class FinalCalculationView < ApplicationRecord
  include Paginatable
  include Searchable

  def raw_calculated
    #F3/H3
    #cost_of_raw_materials_from_lookup / number_of_pieces_per_unit_one
    (raw_material_cost || 0.0 / number_of_pieces_per_unit_one).round 6
  end

  def cost_of_colorant_or_lacquer
    #=SUM(((I3*M3)/H3)+((L3*N3)/K3))

   calc1 = (cost_of_color_one || 0.0 * percentage_of_colorant_one) / number_of_pieces_per_unit_one
   calc2 = (cost_of_color_two || 0.0 * percentage_of_colorant_two) / number_of_pieces_per_unit_two
   (calc1 + calc2).round 6
  end

  def total
    (raw_calculated + cost_of_colorant_or_lacquer).round 4
  end

end
