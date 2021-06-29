module Extractor
  class Base
    include ExcelHelper

    def initialize(spreadsheet)
      @first_row = spreadsheet[ROW_ONE].cells[DATA_RANGE]
      @second_row = spreadsheet[ROW_TWO].cells[DATA_RANGE]
    end

    def map_first_row_cell_values_with_second(first_row_header, second_row_header)
      @first_row_data ||= first_row_cell_values
      @second_row_data ||= second_row_cell_values

      @first_row_data.map.with_index do |cell, index|
        Hash[
          first_row_header, cell[0],
          second_row_header, @second_row_data[index][0]
        ]
      end
    end

    private

    def first_row_cell_values
      sanitize_2d_array_for_nil(
        map_cells_to_cell_value_and_index(@first_row)
      )
    end

    def second_row_cell_values
      sanitize_2d_array_for_nil(
        map_cells_to_cell_value_and_index(@second_row)
      )
    end
  end
end
