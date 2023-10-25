class BlanksListingItemWithCost < ApplicationRecord
  include Paginatable
  include Searchable
  include Upsertable

  belongs_to :blank, foreign_key: :blank_number
  before_save { |record| record.cell_key = item_number + blank_number }

  def self.listing_xlsx(blanks)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Blanks Item Cost") do |sheet|
      sheet.add_row ["ID", "ITEM", "BLANK NUMBER", "COST PER BLANK" ]
      blanks.each do |result|
        item_description = ''

        begin
          @item = Item.find(result.item_number)
          item_description = @item.description
          Rails.logger.info "Blank #{@item}"
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn "No se encontró el ítem con número: #{result.item_number}"
          item_description = ''
        end

        sheet.add_row [result.id, item_description, result.blank_number, result.cost_per_blank]
      end
    end
  
    p.to_stream.read
    end
    
end
