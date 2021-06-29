module Extractor
  class BlanksListingItemWithCost < TakesASpreadsheet
    def records
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?

        cells = row.cells
        item_number = cells[0].value.to_i
        blank_number = cells[2].value.to_i

        Hash[
          item_number: item_number,
          blank_number: blank_number,
          cost_per_blank: cells[3].value.to_f,
          cell_key: item_number.to_s + blank_number.to_s
        ]
      end
    end

    def blank_number_and_cost
      result = records.map do |data|
        Hash[:blank_number, data[:blank_number], :cost, data[:cost_per_blank]]
      end

      result = result.uniq { |r| r[:blank_number] }
    end

    def blank_types
      second_spreadsheet = @original_spreadsheet[1][@data_region]
      second_spreadsheet.delete_if(&:nil?)
      second_spreadsheet.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil? || row.cells[1].nil? || row.cells[1].value.nil?
        Hash[type_number: row.cells[0].value.to_i, description: row.cells[1].value || 'none']
      end.compact
    end
  end
end
