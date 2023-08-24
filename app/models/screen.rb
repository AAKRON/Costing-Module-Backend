# frozen_string_literal: true

class Screen < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  validates :screen_size, presence: true
  validates :cost, presence: true

  def self.listing_xlsx(screens)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Screens") do |sheet|
      sheet.add_row ["ID", "SCREEN_SIZE", "COST" ]
      screens.each do |result|
       
        sheet.add_row [result.id, result.screen_size, result.cost ]
      end
    end
  
    p.to_stream.read
    end
end
