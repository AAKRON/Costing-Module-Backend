module Extractor
  class Item < Base
    def item_number_and_description
      map_first_row_cell_values_with_second(:item_number, :description)
    end
  end
end

