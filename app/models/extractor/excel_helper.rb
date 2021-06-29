module Extractor
  module ExcelHelper
    ROW_ONE = 1
    ROW_TWO = 2
    DATA_RANGE = (5..-1)

    def sanitize_2d_array_for_nil(array)
      array.delete_if { |first, second| first.nil? || second.nil? }
    end

    def map_cells_to_cell_value_and_index(cells)
      cells.map do |cell|
        [cell.value, cell.index_in_collection]
      end
    end
  end
end
