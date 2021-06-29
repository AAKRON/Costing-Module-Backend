module Extractor
  class BlanksReport < TakesASpreadsheet
    def records
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?
        Hash[
          blank_number: row.cells[0].value.to_i, 
          description: row.cells[1].value || 'none',
          blank_type_id: row.cells[2].value.to_i
        ]
      end.compact
    end
  end
end
