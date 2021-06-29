# frozen_string_literal: true
# Box List for Costing Module

class BoxListForCostingModuleJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      Box.bulk_update_or_create(
        Extractor::BoxListForCostingModule.new(spreadsheet).records,
        :name,
        key_as_id: false
      )
    end
  end
end
