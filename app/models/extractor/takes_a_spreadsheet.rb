module  Extractor
  class TakesASpreadsheet
    def initialize(spreadsheet, spreadsheet_index: 0, data_region: 1..-1)
      @spreadsheet = spreadsheet[spreadsheet_index]
      @data_region = data_region
      @original_spreadsheet = spreadsheet
    end

    private

    def rows
      @spreadsheet[@data_region].delete_if(&:nil?)
    end

    def value_or_empty(obj)
      obj.try(:value ) || ''
    end
  end
end
