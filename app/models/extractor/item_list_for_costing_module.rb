module Extractor
  class ItemListForCostingModule < TakesASpreadsheet
    def records
      @lookup = Hash[Box.all.pluck(:name, :id)]
      rows.map do |row|
        next if row.cells[0].nil? || row.cells[0].value.nil?

        Hash[
          item_number: row.cells[0].value.to_i,
          description: row.cells[1].value,
          box_id: @lookup[value_or_empty(row.cells[2])],
          number_of_pcs_per_box: value_or_empty(row.cells[3]).to_i || 0,
          ink_cost: value_or_empty(row.cells[4]).to_f
        ]
      end.compact
    end
  end
end
