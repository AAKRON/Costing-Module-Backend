module Extractor
  class Blank < Base
    def blank_number_and_description
      map_first_row_cell_values_with_second(:blank_number, :description)
    end
  end
end





