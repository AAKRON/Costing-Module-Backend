# frozen_string_literal: true
# JOB LIST ACTUAL Costing Module.xlsx

class ItemsAndBlanksListingJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      first_spreadsheet = spreadsheet[0]
      printf(first_spreadsheet)
      Item.bulk_update_or_create(
        Extractor::Item.new(first_spreadsheet).item_number_and_description,
        :item_number
      )

      JobListing.bulk_update_or_create(
        Extractor::FieldWide.new(first_spreadsheet).job
      )

      ItemJob.bulk_update_or_create_many(
        Extractor::FieldWide.new(first_spreadsheet).spreadsheet_body(
          main_header: :item_id,
          sparse_cell_header: :hour_per_piece
        )
      )

      second_spreadsheet = spreadsheet[1]

      Blank.bulk_update_or_create(
        Extractor::Blank.new(second_spreadsheet).blank_number_and_description,
        :blank_number
      )

      BlankJob.bulk_update_or_create_many(
        Extractor::FieldWide.new(second_spreadsheet).spreadsheet_body(
          main_header: :blank_id,
          sparse_cell_header: :hour_per_piece
        )
      )
    end
  end
end
