class FinalCalculation < ApplicationRecord
  include Paginatable
  include Upsertable

  before_save :set_id_and_cell_key

  belongs_to :blank
  belongs_to :raw_material

  def raw_calculated
    #F3/H3
    #cost_of_raw_materials_from_lookup / number_of_pieces_per_unit_one
    (raw_material.cost / number_of_pieces_per_unit_one).round 6
  end

  def cost_of_colorant_or_lacquer
    #=SUM(((I3*M3)/H3)+((L3*N3)/K3))

   calc1 = (cost_of_color_one * percentage_of_colorant_one) / number_of_pieces_per_unit_one
   calc2 = (cost_of_color_two * percentage_of_colorant_two) / number_of_pieces_per_unit_two
   (calc1 + calc2).round 6
  end

  def total
    (raw_calculated + cost_of_colorant_or_lacquer).round 4
  end

  def average_by_blank; end

  private

  def cost_of_color_one
    Color.where(name: colorant_one)[0].try(:cost_of_color) || 0.0
  end

  def cost_of_color_two
    Color.where(name: colorant_two)[0].try(:color_of_color) || 0.0
  end

  def totals; end

  def average_by_blank; end

  def set_id_and_cell_key
    self.id = self.blank_id.to_s + self.color_number.to_s
    self.cell_key = self.blank_id.to_s + self.color_number.to_s
  end
end
