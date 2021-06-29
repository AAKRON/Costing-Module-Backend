# frozen_string_literal: true
# Blanks Report.xlsx

class BlanksReportJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      Blank.bulk_update_or_create(
        Extractor::BlanksReport.new(spreadsheet).records,
        :blank_number
      )
    end
  end
end
