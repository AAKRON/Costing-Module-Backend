class ItemListForCostingModuleJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      Item.bulk_update_or_create(
        Extractor::ItemListForCostingModule.new(spreadsheet).records,
        :item_number
      )
    end
  end
end
