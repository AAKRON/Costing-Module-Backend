module Extractor
  class ItemsListingWithItemType < TakesASpreadsheet
    def records
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?
        Hash[
          item_number: row.cells[0].value.to_i,
          description: row.cells[1].value || 'none',
          item_type_id: row.cells[2].value.to_i
        ]
      end.compact
    end

    def item_types
      second_spreadsheet = @original_spreadsheet[1][@data_region]
      second_spreadsheet.delete_if(&:nil?)
      second_spreadsheet.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil? || row.cells[1].nil? || row.cells[1].value.nil?
        Hash[type_number: row.cells[0].value.to_i, description: row.cells[1].value || 'none']
      end.compact
    end
  end
end
