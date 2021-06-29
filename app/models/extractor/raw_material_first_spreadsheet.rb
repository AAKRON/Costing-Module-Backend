# frozen_string_literal: true
#numbers indicate cells position

module Extractor
  class RawMaterialFirstSpreadsheet
    def initialize(spreadsheet)
      @first_spreadsheet = spreadsheet[0]
    end

    def color
      rows = @first_spreadsheet[2..-1]
      rows.delete_if(&:nil?)
      rows.map! do |row|
        hash = {}
        next if row.cells[4].nil? && row.cells[6].nil?
        hash[:cost_of_color] = row.cells[4].try(:value) || 0.0
        hash[:name] = row.cells[6].try(:value) || nil
        hash
      end
      rows.compact!
      rows.delete_if { |n| n[:name].nil? }
    end

    def units_of_measure
      extract(data_position: 5)
    end

    def vendor
      extract(data_position: 3)
    end

    def raw_material_type
      extract(data_position: 2)
    end

    private

    def extract(data_position: nil)
      array = @first_spreadsheet[2..-1]
      array.delete_if(&:nil?)
      array.delete_if { |row| row.cells.empty? }
      array.delete_if { |row| row.cells[data_position].nil? }
      array.delete_if { |row| row.cells[data_position].value.nil? }
      array.map! { |row| row.cells[data_position].value }
      array.uniq
    end
  end
end
