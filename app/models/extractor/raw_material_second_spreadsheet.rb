# frozen_string_literal: true
#numbers indicate cells position

module Extractor
  class RawMaterialSecondSpreadsheet
    DATA_REGION = {
      blank_number: 0,
      color_number: 1,
      color_description: 3,
      raw_material: 4,
      colorant_one: 6,
      number_of_pieces_per_unit_one: 7,
      colorant_two: 9,
      number_of_pieces_per_unit_two: 10,
      percentage_of_colorant_one: 12,
      percentage_of_colorant_two: 13
    }

    def initialize(spreadsheet)
      @second_spreadsheet = spreadsheet[1]
      @lookup = Hash[RawMaterial.all.pluck(:name, :id)]
    end

    def data
      rows = @second_spreadsheet[1..-1]
      rows.delete_if(&:nil?)
      rows.map! do |row|
        blank_id = value_or_empty row[DATA_REGION[:blank_number]]
        next if blank_id == ''

        hash = {}
        hash[:blank_id] = blank_id
        hash[:color_number] = value_or_empty row[DATA_REGION[:color_number]]
        hash[:color_description] = value_or_empty row[DATA_REGION[:color_description]]
        hash[:raw_material_id] = @lookup[value_or_empty(row[DATA_REGION[:raw_material]])]
        hash[:colorant_one] = value_or_empty row[DATA_REGION[:colorant_one]]
        hash[:number_of_pieces_per_unit_one] = value_or_empty row[DATA_REGION[:number_of_pieces_per_unit_one]]
        hash[:colorant_two] = value_or_empty row[DATA_REGION[:colorant_two]]
        hash[:number_of_pieces_per_unit_two] = value_or_empty row[DATA_REGION[:number_of_pieces_per_unit_two]]
        hash[:percentage_of_colorant_one] = value_or_empty row[DATA_REGION[:percentage_of_colorant_one]]
        hash[:percentage_of_colorant_two] = value_or_empty row[DATA_REGION[:percentage_of_colorant_two]]
        hash[:cell_key] = blank_id.to_s + hash[:color_number].to_s
        hash
      end.compact
    end

    private

    def value_or_empty(obj)
      obj.try(:value ) || ''
    end
  end
end
