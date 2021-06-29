module Extractor
  class BoxListForCostingModule < TakesASpreadsheet
    def records
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?
        Hash[name: row.cells[0].value, cost_per_box: row.cells[1].value.to_f]
      end.compact
    end
  end
end
