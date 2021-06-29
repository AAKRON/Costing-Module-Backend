module Extractor
  class BlanksListingByItem < TakesASpreadsheet
    def records
      rows.delete_if(&:nil?)

      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?

        item_number = row.cells[0].value.to_i
        blank_number = value_or_empty(row.cells[2]).to_i

        Hash[
          item_number: item_number,
          blank_number: blank_number,
          mult: value_or_empty(row.cells[3]).to_i,
          div: value_or_empty(row.cells[4]).to_i,
          cell_key: item_number.to_s + blank_number.to_s
        ]
      end
    end
  end
end
