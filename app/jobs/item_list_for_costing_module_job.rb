class ItemListForCostingModuleJob < ApplicationJob
  queue_as :default
  include Paginatable
  include Searchable
  include Upsertable


  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|
      Item.bulk_update_or_create(
        Extractor::ItemListForCostingModule.new(spreadsheet).records,
        :item_number
      )
    end
  end


  def self.listing_xlsx(items)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Item List") do |sheet|
      sheet.add_row ["ID", "ITEM_NUMBER", "DESCRIPTION", "BOX_ID", "NUMBER_OF_PCS_PER_BOX","INK_COST","ITEM_TYPE_ID"]
      items.each do |result|
        # item_description = ''

        # begin
        #   @item = Item.find(result.item_number)
        #   item_description = @item.description
        #   Rails.logger.info "ITEM #{@item}"
        # rescue ActiveRecord::RecordNotFound => e
        #   Rails.logger.warn "No se encontró el ítem con número: #{result.item_number}"
        #   item_description = ''
        # end

        sheet.add_row [result.id, result.item_number, result.description, result.box_id, result.number_of_pcs_per_box, result.ink_cost, result.item_type_id]
      end
    end
  
    p.to_stream.read
    end
end
