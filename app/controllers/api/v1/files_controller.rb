# frozen_string_literal: true
require "pdfkit"
require 'roo'
module Api
  module V1
    class FilesController < BaseController
      BACKGROUND_JOB_CLASS_FOR = {
        jobs_and_blanks: ItemsAndBlanksListingJob,
        raw_materials: RawMaterialsJob,
        blanks_listing_item_with_cost: BlanksListingItemWithCostJob,
        blanks_listing_by_item: BlanksListingByItemJob,
        box_list_for_costing_module: BoxListForCostingModuleJob,
        screen_cliche_sizes_for_costing_module: ScreenClicheSizesForCostingModuleJob,
        item_list_for_costing_module: ItemListForCostingModuleJob,
        blanks_report: BlanksReportJob,
        item_listing_with_item_types: ItemsListingWithItemTypeJob
      }

      def items_and_blanks_listings
        file = params[:file]
        file_params = {
          filename: File.basename(file.original_filename),
          content_type: file.content_type,
          file_content: Base64.encode64(file.read),
          document_type: params[:document_type]
        }

        Document.where(document_type: params[:document_type]).destroy_all

        document = Document.new(file_params.slice(:filename, :content_type, :file_content, :document_type))
        if document.save
          if background_job_class = BACKGROUND_JOB_CLASS_FOR[params[:document_type].to_sym]
            background_job_class.perform_later(document.file_content, document.filename.downcase.gsub(' ', '_'))
            render json: { message: 'You file is being processed.' }, status: :ok
          end
        else
          render json: { message: document.errors }, status: :bad_request
        end
      end

      def download
        @document = Document.find_by_document_type(params[:file_type])

        send_data Base64.decode64(@document.file_content), filename: @document.filename, type: @document.content_type
      end

      def item_download

        if (params.key?("items") && params[:items] !='')
          items = params[:items].split(",")
          @items = ItemCostView.where(item_number: items).order(:item_number)
        else
          @items = ItemCostView.all.order(:item_number)
        end

        respond_to do |format|
            format.csv { send_data params[:cost_type] == 'item-price-cost' ? @items.to_price_csv : @items.to_invetory_csv }
        end
      end

      def blank_download

        if (params.key?("blanks") && params[:blanks] !='')
          blanks = params[:blanks].split(",")
          @blanks = BlankCostView.where("type_number = 1").where(blank_number: blanks).order(:blank_number)
        else
          @blanks = BlankCostView.where("type_number = 1").order(:blank_number)
        end

        respond_to do |format|
            format.csv { send_data params[:cost_type] == 'blank-price-cost' ? @blanks.to_price_csv : @blanks.to_invetory_csv }
        end
      end


      def raw_material_download

        if (params.key?("blanks") && params[:blanks] !='')
          raws = params[:blanks].split(",")          
          @raws = RawMaterialView.where(id: raws).order(:id)
        else
          @raws = RawMaterialView.order(:id)
        end

        respond_to do |format|
            format.csv { send_data @raws.listing_csv}
        end
      end

      def raw_material_type_download

        if (params.key?("blanks") && params[:blanks] !='')
          rawstypes = params[:blanks].split(",")          
          @rawstypes = Rawmaterialtype.where(id: rawstypes).order(:id)
        else
          @rawstypes = Rawmaterialtype.order(:id)
        end

        respond_to do |format|
            format.csv { send_data @rawstypes.listing_csv}
        end
      end

      def color_download

        if (params.key?("blanks") && params[:blanks] !='')
          colors = params[:blanks].split(",")          
          @colors = Color.where(id: colors).order(:id)
        else
          @colors = Color.order(:id)
        end

        respond_to do |format|
            format.csv { send_data @colors.listing_csv}
        end
      end

      def units_download

        if (params.key?("blanks") && params[:blanks] !='')
          units = params[:blanks].split(",")          
          @units = UnitsOfMeasure.where(id: units).order(:id)
        else
          @units = UnitsOfMeasure.order(:id)
        end

        respond_to do |format|
            format.csv { send_data @units.listing_csv}
        end
      end

      def vendors_download

        if (params.key?("blanks") && params[:blanks] !='')
          vendors = params[:blanks].split(",")          
          @vendors = Vendor.where(id: vendors).order(:id)
        else
          @vendors = Vendor.order(:id)
        end
        respond_to do |format|
            format.csv { send_data @vendors.listing_csv}
        end
      end
      
      def update_or_create_jobs      
      
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            job_id = row[0].to_i
            job = JobListing.find_or_initialize_by(id: job_id)
      
            if job.new_record?
              Rails.logger.info "Creating new job with id: #{job_id}"
              created += 1
            else
              Rails.logger.info "Updating job with id: #{job_id}"
              updated += 1
            end
      
            wages_per_hour = row[2].to_f
            job.update(description: row[1], wages_per_hour: wages_per_hour)
          end
        end
      
        Rails.logger.info "Jobs updated: #{updated}"
        Rails.logger.info "Jobs created: #{created}"
      
        render json: { message: "Your Jobs were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end    

      def update_or_create_raw_materials
        begin
          file = params[:file]
          xlsx = Roo::Spreadsheet.open(file.path)
      
          updated = 0
          created = 0
      
          Rails.logger.info "Reading Excel file..."
      
          xlsx.sheets.each do |sheet|
            Rails.logger.info "Reading sheet: #{sheet}"
            current_sheet = xlsx.sheet(sheet)
            num_rows = current_sheet.last_row
            Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
            2.upto(num_rows) do |i|
              row = current_sheet.row(i)
              Rails.logger.info  "#{row[1]}"
              raw_material_id = row[0].to_i
              raw_material = RawMaterial.find_or_initialize_by(id: raw_material_id)
      
              if raw_material.new_record?
                Rails.logger.info "Creating new raw material with id: #{raw_material_id}"
                created += 1
              else
                Rails.logger.info "Updating raw material with id: #{raw_material_id}"
                updated += 1
              end
              
              cost = row[2].to_f
              raw_material.update(name: row[1], cost: cost)
            end
          end
      
          Rails.logger.info "Raw materials updated: #{updated}"
          Rails.logger.info "Raw materials created: #{created}"
      
          render json: { message: "Your raw materials were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
        rescue => e
          Rails.logger.error "Error: #{e.message}"
          render json: { message: e.message }, status: :bad_request
        end
      end
      

        
      def update_or_create_boxes       
      
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            box_id = row[0].to_i
            box = Box.find_or_initialize_by(id: box_id)
      
            if box.new_record?
              Rails.logger.info "Creating new box with id: #{box_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{box_id}"
              updated += 1
            end
      
            cost_per_box = row[2].to_f
            box.update(name: row[1], cost_per_box: cost_per_box)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your boxes were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end    
      
    
      def update_or_create_blanks_listing_item_with_cost     
      
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id= row[0].to_i
            Rails.logger.info "id: #{item_id}"

            item = BlanksListingItemWithCost.find(item_id)
            Rails.logger.info "item: #{item}"
      
            if item.new_record?
              Rails.logger.info "Creating new box with id: #{item_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{item_id}"
              updated += 1
            end
      
            cost_per_blank = row[3].to_f
            Rails.logger.info "cost_per_blank: #{cost_per_blank}"

            item.update(cost_per_blank: cost_per_blank)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end    

      
      def update_or_create_blanks_listing_by_item
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id= row[0].to_i
            Rails.logger.info "id: #{item_id}"

            item = BlanksListingByItem.find(item_id)
            Rails.logger.info "item: #{item}"
      
            if item.new_record?
              Rails.logger.info "Creating new box with id: #{item_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{item_id}"
              updated += 1
            end
      
            mult = row[3].to_f
            div = row[4].to_f
            Rails.logger.info "mult: #{mult}"
            Rails.logger.info "div: #{div}"

            item.update(mult: mult, div: div)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end   


      def update_or_create_item_list_for_costing_module
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id= row[0].to_i
            Rails.logger.info "id: #{item_id}"

            item = Item.find(item_id)
            Rails.logger.info "item: #{item}"
      
            if item.new_record?
              Rails.logger.info "Creating new box with id: #{item_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{item_id}"
              updated += 1
            end
            
            description = row[2]
            number_of_pcs_per_box = row[4].to_f
            ink_cost = row[5].to_f          
            Rails.logger.info "description: #{description}"
            Rails.logger.info "dinumber_of_pcs_per_boxv: #{number_of_pcs_per_box}"
            Rails.logger.info "ink_cost: #{ink_cost}"

            item.update(description: description, number_of_pcs_per_box: number_of_pcs_per_box,ink_cost:ink_cost)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end   

      def update_or_create_screen_cliche_sizes_for_costing_module
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            screen_id= row[0].to_i
            Rails.logger.info "id: #{screen_id}"

            screen = Screen.find(screen_id)
            Rails.logger.info "screen: #{screen}"
      
            if screen.new_record?
              Rails.logger.info "Creating new box with id: #{screen_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{screen_id}"
              updated += 1
            end
            
            cost = row[2].to_f                    
            Rails.logger.info "cost: #{cost}"
            screen.update(cost: cost)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end   

      def update_or_create_blanks_report
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            blank_id= row[0].to_i
            Rails.logger.info "id: #{blank_id}"

            blank = Blank.find(blank_id)
            Rails.logger.info "screen: #{blank}"
      
            if blank.new_record?
              Rails.logger.info "Creating new box with id: #{blank_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{blank_id}"
              updated += 1
            end
            
            blank_type_id = row[2]                 
            Rails.logger.info "blank_type_id: #{blank_type_id}"
            blank.update(blank_type_id: blank_type_id)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end  

      def update_or_create_item_listing_with_item_types
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)
      
        updated = 0
        created = 0
      
        Rails.logger.info "Reading Excel file..."
      
        xlsx.sheets.each do |sheet|
          Rails.logger.info "Reading sheet: #{sheet}"
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row
          Rails.logger.info "Number of rows in sheet: #{num_rows}"
      
          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id= row[0].to_i
            Rails.logger.info "id: #{item_id}"

            item = Item.find(item_id)
            Rails.logger.info "screen: #{item}"
      
            if item.new_record?
              Rails.logger.info "Creating new box with id: #{item_id}"
              created += 1
            else
              Rails.logger.info "Updating box with id: #{item_id}"
              updated += 1
            end
            
            item_type_id = row[2]                 
            Rails.logger.info "item_type_id: #{item_type_id}"
            item.update(item_type_id: item_type_id)
          end
        end
      
        Rails.logger.info "Boxes updated: #{updated}"
        Rails.logger.info "Boxes created: #{created}"
      
        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end  


      def job_listing_download  
        @jobslisting = JobListing.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data JobListing.listing_xlsx(@jobslisting), filename: "1 - JOB LIST ACTUAL COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end   

      def raw_materials
        @raws = RawMaterial.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data RawMaterial.listing_xlsx(@raws), filename: "2 - NEW RAW CAL.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end

      end

      def blanks_listing_item_with_cost_download  
        @blankslisting = BlanksListingItemWithCost.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data BlanksListingItemWithCost.listing_xlsx(@blankslisting), filename: "3 - BLANKS LISTING ITEM WITH COST.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end   

      def blanks_listing_by_item_download  
        @blankslisting = BlanksListingByItem.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data BlanksListingByItem.listing_xlsx(@blankslisting), filename: "4 - BLANKS LISTING BY ITEM.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end   

      def box_download       
        @boxes = Box.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data Box.listing_xlsx(@boxes), filename: "5 - BOX LIST FOR COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end      

      def item_list_for_costing_module_download
        @itemcostingmodule = Item.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data ItemListForCostingModuleJob.listing_xlsx(@itemcostingmodule), filename: "6 - ITEM LIST FOR COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end  

      def screen_cliche_sizes_for_costing_module_download
        @screens = Screen.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data Screen.listing_xlsx(@screens), filename: "7 - SCREEN-CLICHE SIZES FOR COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end  


      def blanks_report_download
        @blanks = Blank.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data Blank.listing_xlsx(@blanks), filename: "8-BLANKS REPORT.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end  

      def item_listing_with_item_types_download
        @items = Item.all.order(:id)      
        respond_to do |format|
          format.xlsx { send_data ItemsListingWithItemTypeJob.listing_xlsx(@items), filename: "9-ITEM LISTING WITH ITEM TYPES.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end  


      def cost_pdf_download
        @cost_data = params[:data]
        kit = PDFKit.new(to_cost_calculator_html, page_size: 'A4')
        pdf = kit.to_pdf

        Document.where(document_type: 'item_cost_invoice').destroy_all

        file_params = {
          filename: "item-cost-invoice.pdf",
          content_type: "application/pdf",
          file_content: Base64.encode64(pdf),
          document_type: "item_cost_invoice"
        }

        document = Document.new(file_params.slice(:filename, :content_type, :file_content, :document_type))
        if document.save
          render json: { message: 'You file is being processed.' }, status: :ok
        else
          render json: { message: document.errors }, status: :bad_request
        end
      end

      private

      def file_params
        params.permit(:file)
      end

      def to_cost_calculator_html
        render_to_string(template: 'api/v1/file/cost_calculator.html.erb', :layout => false, :disposition => 'inline', locals: {cost_data: @cost_data})
      end
    end
  end
end
