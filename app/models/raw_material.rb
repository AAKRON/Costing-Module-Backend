# frozen_string_literal: true
class RawMaterial < ApplicationRecord
  include Paginatable
  include Paginatable
  include Searchable

  validates :name, uniqueness: true

  belongs_to :units_of_measure, optional: true
  belongs_to :color, optional: true
  belongs_to :rawmaterialtype, optional: true
  belongs_to :vendor, optional: true


  def self.listing_xlsx(raws)
    p = Axlsx::Package.new
    wb = p.workbook
  
    wb.add_worksheet(name: "Raw Material") do |sheet|
      # sheet.add_row ["ID", "NAME", "COST",'UNITS_OF_MEASURE_ID', 'COLOR_ID', 'VENDOR_ID','RAWMATERIALTYPE_ID']
      sheet.add_row ["ID", "NAME", "COST"]
      raws.each do |result|
        sheet.add_row [result.id, result.name, result.cost]
      end
    end
  
    p.to_stream.read
  end
end
