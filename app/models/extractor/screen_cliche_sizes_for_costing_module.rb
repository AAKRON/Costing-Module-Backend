module Extractor
  class ScreenClicheSizesForCostingModule < TakesASpreadsheet
    def records
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?
        Hash[screen_size: row.cells[0].value.strip, cost: row.cells[1].value.to_f.round(5)]
      end.compact
    end
  end
end
