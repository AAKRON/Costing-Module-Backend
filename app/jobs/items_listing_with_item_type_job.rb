class ItemsListingWithItemTypeJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|

      ItemType.bulk_update_or_create(
        Extractor::ItemsListingWithItemType.new(spreadsheet).item_types,
        :type_number,
        key_as_id: false
      )

      Item.bulk_update_or_create(
        Extractor::ItemsListingWithItemType.new(spreadsheet).records,
        :item_number
      )
    end
  end
end
