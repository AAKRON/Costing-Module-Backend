# frozen_string_literal: true
module Extractor
  class RawMaterialListing
    def initialize(spreadsheet, extracted_data)
      @first_spreadsheet = spreadsheet[0]
      @vendor = create_hash_map(Vendor, extracted_data.vendor)
      @raw_material_type = create_hash_map(Rawmaterialtype, extracted_data.raw_material_type)
      color = extracted_data.color.map { |c| c[:name] }; color.uniq!
      @color = create_hash_map(Color, color)
      @unit_of_measure = create_hash_map(UnitsOfMeasure, extracted_data.units_of_measure)
    end

    def extract
      rows = @first_spreadsheet[2..-1]
      rows.delete_if(&:nil?)
      rows.map do |row|
        name = row.cells[1].try(:value) || ''
        next if name == ''

        hash = {}
        hash[:name] =  name
        hash[:rawmaterialtype_id] = @raw_material_type[row.cells[2].try(:value) || 'undefined'] || nil
        hash[:vendor_id] = @vendor[row.cells[3].try(:value) || 'undefined'] || nil
        hash[:cost] = row.cells[4].try(:value) || '0.0'
        hash[:units_of_measure_id] = @unit_of_measure[row.cells[5].try(:value) || 'undefined'] || nil
        hash[:color_id] = @color[row.cells[6].try(:value) || 'undefined'] || nil
        hash
      end
    end

    private

    def create_hash_map(klass, data)
      Hash[klass.where(name: data).pluck(:name, :id)]
    end
  end
end
