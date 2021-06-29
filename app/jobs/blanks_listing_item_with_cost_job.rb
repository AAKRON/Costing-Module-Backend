class BlanksListingItemWithCostJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      BlanksListingItemWithCost.bulk_update_or_create(
        Extractor::BlanksListingItemWithCost.new(spreadsheet).records,
        :cell_key,
        key_as_id: false
      )

      BlankType.bulk_update_or_create(
        Extractor::BlanksListingItemWithCost.new(spreadsheet).blank_types,
        :type_number,
        key_as_id: false
      )

      Blank.bulk_update_or_create(
        Extractor::BlanksListingItemWithCost.new(spreadsheet).blank_number_and_cost,
        :blank_number
      )
    end
  end
end
