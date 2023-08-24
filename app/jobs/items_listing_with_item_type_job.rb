class ItemsListingWithItemTypeJob < ApplicationJob
  queue_as :default

  def perform(file_content, filename)
    Base64StringToSpreadsheet.perform(base_64_string: file_content, filename: filename) do |spreadsheet|

      ItemType.bulk_update_or_create(
        Extractor::ItemsListingWithItemType.new(spreadsheet).item_types,
        :type_number,
        key_as_id: false
      )

      Item.bulk_update_or_create(
        Extractor::ItemsListingWithItemType.new(spreadsheet).records,
        :item_number
      )
    end
  end

  def self.listing_xlsx(items)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Items with item types") do |sheet|
      sheet.add_row ["ID", "DESCRIPTION", "ITEM_TYPE_ID","ITEM_TYPE" ]
      items.each do |result|
        begin
          @itemtype = ItemType.find_by(type_number: result.item_type_id)  # Cambiado: Usar type_number
          item_type = @itemtype.description if @itemtype  # Corregido: Verificar si se encontró un ItemType
          Rails.logger.info "ITEM_TYPE #{@itemtype}" if @itemtype  # Cambiado: Loggear el tipo de ítem encontrado
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn "No se encontró el ítem con número: #{result.item_type_id}"
          item_type = ''
        end

        sheet.add_row [result.id, result.description, result.item_type_id, item_type ]
      end
    end
  
    p.to_stream.read
    end


end
