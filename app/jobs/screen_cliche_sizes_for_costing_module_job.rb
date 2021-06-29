# frozen_string_literal: true
# Screen-Cliche Sizes for Costing Module.xlsx

class ScreenClicheSizesForCostingModuleJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      Screen.bulk_update_or_create(
        Extractor::ScreenClicheSizesForCostingModule.new(spreadsheet).records,
        :screen_size,
        key_as_id: false
      )
    end
  end
end
