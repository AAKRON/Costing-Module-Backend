# frozen_string_literal: true
# Copy of New Raw Cal .xlsx

class RawMaterialsJob < ApplicationJob
  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      extracted_data = Extractor::RawMaterialFirstSpreadsheet.new(spreadsheet)

      Color.bulk_update_or_create(extracted_data.color)
      UnitsOfMeasure.bulk_update_or_create(extracted_data.units_of_measure)
      Vendor.bulk_update_or_create(extracted_data.vendor)
      Rawmaterialtype.bulk_update_or_create(extracted_data.raw_material_type)

      RawMaterial.create(
        Extractor::RawMaterialListing.new(spreadsheet, extracted_data).extract
      )

      FinalCalculation.bulk_update_or_create(
        Extractor::RawMaterialSecondSpreadsheet.new(spreadsheet).data,
        :cell_key
      )
    end
  end
end
