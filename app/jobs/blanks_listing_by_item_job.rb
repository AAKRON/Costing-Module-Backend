class BlanksListingByItemJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      BlanksListingByItem.bulk_update_or_create(
        Extractor::BlanksListingByItem.new(spreadsheet).records,
        :cell_key,
        key_as_id: false
      )
    end
  end

end
