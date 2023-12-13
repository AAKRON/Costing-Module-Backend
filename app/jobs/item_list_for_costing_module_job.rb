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


  def self.show_item_xlsx(item)
    p = Axlsx::Package.new
    wb = p.workbook
    only_bold_style = wb.styles.add_style(b: true)
    bold_style = wb.styles.add_style(b: true, alignment: { horizontal: :left, vertical: :center }, border: { style: :thin, color: 'cccccc', edges: [:top, :bottom] })
    bordered_style = wb.styles.add_style(alignment: { horizontal: :left, vertical: :center }, border: { style: :thin, color: 'cccccc', edges: [:top, :bottom] }) # Define a style with borders

    wb.add_worksheet(name: "Item List") do |sheet|
        # Start document content
        sheet.add_row ["ITEM REPORT"], style: [only_bold_style]
        sheet.add_row []
        sheet.add_row ["ID", "ITEM_NUMBER", "DESCRIPTION", "BOX_ID", "NUMBER_OF_PCS_PER_BOX","INK_COST","ITEM_TYPE_ID"]
        sheet.add_row [item['id'], item['item_number'], item['description'], item['box_id'], item['number_of_pcs_per_box'], item['ink_cost'], item['item_type_id']]

        # Add prices costs table
        sheet.add_row []
        sheet.add_row []
        sheet.add_row ["Price Cost($): $#{item['total_price_cost']}"], style: [only_bold_style]
        sheet.add_row []

        sheet.add_row ["Blanks", "Blank", "Blank Type", "Cost($)", "Multiplication", "Division", "Cost($)"]
        item['blanks'].each do |blank|
            sheet.add_row ["", "#{blank['blank_number']}-#{blank['description']}", blank['blank_type'], "$#{blank['total_blank_cost_for_price']}", blank['multiplication'], blank['division'], "$#{blank['total_blank_cost_for_price_modify']}"]
        end

        sheet.add_row ["Jobs", "Job", "Wages($)/hr", "Hr/pcs", "Direct Labor ($)", "Overhead Price", "Cost($)"]
        item['jobs'].each do |job|
            sheet.add_row ["", "#{job['job_number']}-#{job['description']}", "$#{job['wages_per_hour']}", job['hour_per_piece'], "$#{job['direct_labor_cost']}", "$#{job['overhead_pricing_cost']}", "$#{job['total_pricing_cost']}"]
        end

        sheet.add_row ["Screens", "Job", "", "", "Screen Name", "", "Cost($)"]
        item['screen'].each do |screen|
            sheet.add_row ["", "#{screen['job_number']}-#{screen['description']}", "", "", screen['screen_name'], "", "$#{screen['screen_cost']}"]
        end

        sheet.add_row ["Box", "Name", "", "Cost", "Number Of pcs/box", "", "Cost($)"]
        sheet.add_row ["", item['box_name'], "", "$#{item['box_cost']}", item['number_of_pcs_per_box'], "", "$#{item['item_box_cost']}"]

        sheet.add_row ["Ink Cost", "", "", "", "", "", "$#{item['ink_cost']}"]
        sheet.add_row ["", "", "", "", "", "Total Price Cost($)", "$#{item['total_price_cost']}"]

        # Add inventory costs table
        sheet.add_row []
        sheet.add_row []
        sheet.add_row ["Inventory Cost($): $#{item['total_inventory_cost']}"], style: [only_bold_style]
        sheet.add_row []

        sheet.add_row ["Blanks", "Blank", "Blank Type", "Cost($)", "Multiplication", "Division", "Cost($)"]
        item['blanks'].each do |blank|
            sheet.add_row ["", "#{blank['blank_number']}-#{blank['description']}", blank['blank_type'], "$#{blank['total_blank_cost_for_inventory']}", blank['multiplication'], blank['division'], "$#{blank['total_blank_cost_for_inventory_modify']}"]
        end

        sheet.add_row ["Jobs", "Job", "Wages($)/hr", "Hr/pcs", "Direct Labor ($)", "Overhead Price", "Cost($)"]
        item['jobs'].each do |job|
            sheet.add_row ["", "#{job['job_number']}-#{job['description']}", "$#{job['wages_per_hour']}", job['hour_per_piece'], "$#{job['direct_labor_cost']}", "$#{job['overhead_inventory_cost']}", "$#{job['total_inventory_cost']}"]
        end

        sheet.add_row ["Screens", "Job", "", "", "Screen Name", "", "Cost($)"]
        item['screen'].each do |screen|
            sheet.add_row ["", "#{screen['job_number']}-#{screen['description']}", "", "", screen['screen_name'], "", "$#{screen['screen_cost']}"]
        end

        sheet.add_row ["Box", "Name", "", "Cost", "Number Of pcs/box", "", "Cost($)"]
        sheet.add_row ["", item['box_name'], "", "$#{item['box_cost']}", item['number_of_pcs_per_box'], "", "$#{item['item_box_cost']}"]

        sheet.add_row ["Ink Cost", "", "", "", "", "", "$#{item['ink_cost']}"]
        sheet.add_row ["", "", "", "", "", "Total Inventory Cost($)", "$#{item['total_inventory_cost']}"]

        # Merge cells
        num_blanks = item['blanks'].length
        num_jobs = item['jobs'].length
        num_screens = item['screen'].length
        start_cell = 9

        # Price cost table
        end_blanks_cell = start_cell + num_blanks
        sheet.merge_cells("A#{start_cell}:A#{end_blanks_cell}")
        end_jobs_cell = end_blanks_cell + 1 + num_jobs
        sheet.merge_cells("A#{end_blanks_cell + 1}:A#{end_jobs_cell}")
        end_screens_cell = end_jobs_cell + 1 + num_screens
        sheet.merge_cells("A#{end_jobs_cell + 1}:A#{end_screens_cell}")
        sheet.merge_cells("A#{end_screens_cell + 1}:A#{end_screens_cell + 2}")

        # inventory cost table
        start_cell_inv = end_screens_cell + 9
        end_blanks_cell_inv = start_cell_inv + num_blanks
        sheet.merge_cells("A#{start_cell_inv}:A#{end_blanks_cell_inv}")
        end_jobs_cell_inv = end_blanks_cell_inv + 1 + num_jobs
        sheet.merge_cells("A#{end_blanks_cell_inv + 1}:A#{end_jobs_cell_inv}")
        end_screens_cell_inv = end_jobs_cell_inv + 1 + num_screens
        sheet.merge_cells("A#{end_jobs_cell_inv + 1}:A#{end_screens_cell_inv}")
        sheet.merge_cells("A#{end_screens_cell_inv + 1}:A#{end_screens_cell_inv + 2}")


        # - Customize gridlines
        sheet.sheet_view.show_grid_lines = false # Disable gridlines
        sheet["A3:G3"].each { |cell| cell.style = bold_style }
        sheet['A4:G4'].each { |cell| cell.style = bordered_style }

        # Price cost table
        sheet["A#{start_cell}:G#{end_screens_cell}"].each { |cell| cell.style = bordered_style }
        sheet["A#{start_cell}:G#{start_cell}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_blanks_cell + 1}:G#{end_blanks_cell + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_jobs_cell + 1}:G#{end_jobs_cell + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_screens_cell + 1}:G#{end_screens_cell + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_screens_cell + 3}:G#{end_screens_cell + 4}"].each { |cell| cell.style = bold_style }

        # inventory cost table
        sheet["A#{start_cell_inv}:G#{end_screens_cell_inv}"].each { |cell| cell.style = bordered_style }
        sheet["A#{start_cell_inv}:G#{start_cell_inv}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_blanks_cell_inv + 1}:G#{end_blanks_cell_inv + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_jobs_cell_inv + 1}:G#{end_jobs_cell_inv + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_screens_cell_inv + 1}:G#{end_screens_cell_inv + 1}"].each { |cell| cell.style = bold_style }
        sheet["A#{end_screens_cell_inv + 3}:G#{end_screens_cell_inv + 4}"].each { |cell| cell.style = bold_style }
    end

    p.to_stream.read
  end
end
