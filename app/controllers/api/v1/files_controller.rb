# frozen_string_literal: true
require "pdfkit"
require 'roo'

module Api
  module V1
    class FilesController < BaseController
      # Ensure DB switch happens before anything else in this controller
      before_action :set_current_database, prepend: true
      # Prepare location info after DB is switched
      before_action :prepare_location_and_year

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
      }.freeze

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
        items = params.key?("items") && params[:items].present? ? params[:items].split(",") : nil
        puts "Current DB USED: #{ActiveRecord::Base.connection.current_database}"
        if !@database_location_exists
          @items = items.present? ? ItemCostView.where(item_number: items).order(:item_number) : ItemCostView.all.order(:item_number)
        else
          _location_id = @location ? @location.id : 0
          @items = ItemCostView.filter_items_id_by_location(_location_id, items)
        end

        respond_to do |format|
          format.csv { send_data (params[:cost_type] == 'item-price-cost' ? ItemCostView.to_price_csv(@items) : ItemCostView.to_invetory_csv(@items)) }
        end
      end

      def blank_download
        if !@database_location_exists
          if (params.key?("blanks") && params[:blanks].present?)
            blanks = params[:blanks].split(",")
            @blanks = BlankCostView.where(blank_number: blanks).order(:blank_number)
          else
            @blanks = BlankCostView.order(:blank_number)
          end
        else
          blanks = (params.key?("blanks") && params[:blanks].present?) ? params[:blanks] : nil
          _location_id = @location ? @location.id : 0
          @blanks = BlankCostView.filter_by_blanks_numbers_location(_location_id, blanks)
        end

        respond_to do |format|
          format.csv { send_data (params[:cost_type] == 'blank-price-cost' ? BlankCostView.to_price_csv(@blanks) : BlankCostView.to_invetory_csv(@blanks)) }
        end
      end

      def raw_material_download
        if !@database_location_exists
          if (params.key?("blanks") && params[:blanks].present?)
            raws = params[:blanks].split(",")
            @raws = RawMaterialView.where(id: raws).order(:id)
          else
            @raws = RawMaterialView.order(:id)
          end
        else
          raws = (params.key?("blanks") && params[:blanks].present?) ? params[:blanks] : nil
          _location_id = @location ? @location.id : 0
          @raws = RawMaterialView.filter_raw_materials_by_location(_location_id, raws)
        end

        respond_to do |format|
          format.csv { send_data RawMaterialView.listing_csv(@raws) }
        end
      end

      def raw_material_type_download
        if (params.key?("blanks") && params[:blanks].present?)
          rawstypes = params[:blanks].split(",")
          @rawstypes = Rawmaterialtype.where(id: rawstypes).order(:id)
        else
          @rawstypes = Rawmaterialtype.order(:id)
        end

        respond_to do |format|
          format.csv { send_data @rawstypes.listing_csv }
        end
      end

      def color_download
        if !@database_location_exists
          if (params.key?("blanks") && params[:blanks].present?)
            colors = params[:blanks].split(",")
            @colors = Color.where(id: colors).order(:id)
          else
            @colors = Color.order(:id)
          end
        else
          colors = (params.key?("blanks") && params[:blanks].present?) ? params[:blanks] : nil
          _location_id = @location ? @location.id : 0
          @colors = ColorsView.filter_by_colors_location(_location_id, colors)
        end

        respond_to do |format|
          format.csv { send_data Color.listing_csv(@colors) }
        end
      end

      def units_download
        if (params.key?("blanks") && params[:blanks].present?)
          units = params[:blanks].split(",")
          @units = UnitsOfMeasure.where(id: units).order(:id)
        else
          @units = UnitsOfMeasure.order(:id)
        end

        respond_to do |format|
          format.csv { send_data @units.listing_csv }
        end
      end

      def vendors_download
        if (params.key?("blanks") && params[:blanks].present?)
          vendors = params[:blanks].split(",")
          @vendors = Vendor.where(id: vendors).order(:id)
        else
          @vendors = Vendor.order(:id)
        end

        respond_to do |format|
          format.csv { send_data @vendors.listing_csv }
        end
      end

      # -------------------------
      # Excel import/update actions
      # -------------------------
      def update_or_create_jobs
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)

        updated = 0
        created = 0

        Rails.logger.info "Reading Excel file..."

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            job_id = row[0].to_i
            job = JobListing.find_or_initialize_by(id: job_id)

            if job.new_record?
              created += 1
            else
              updated += 1
            end

            wages_per_hour = row[2].to_f
            job.update(description: row[1], wages_per_hour: wages_per_hour)
          end
        end

        render json: { message: "Your Jobs were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end

      def update_or_create_raw_materials
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)

        updated = 0
        created = 0

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            raw_material_id = row[0].to_i
            raw_material = RawMaterial.find_or_initialize_by(id: raw_material_id)

            if raw_material.new_record?
              created += 1
            else
              updated += 1
            end

            cost = row[2].to_f
            raw_material.update(name: row[1], cost: cost)
          end
        end

        render json: { message: "Your raw materials were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end

      def update_or_create_boxes
        file = params[:file]
        xlsx = Roo::Spreadsheet.open(file.path)

        updated = 0
        created = 0

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            box_id = row[0].to_i
            box = Box.find_or_initialize_by(id: box_id)

            if box.new_record?
              created += 1
            else
              updated += 1
            end

            cost_per_box = row[2].to_f
            box.update(name: row[1], cost_per_box: cost_per_box)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id = row[0].to_i
            item = BlanksListingItemWithCost.find_or_initialize_by(id: item_id)

            if item.new_record?
              created += 1
            else
              updated += 1
            end

            cost_per_blank = row[3].to_f
            item.update(cost_per_blank: cost_per_blank)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id = row[0].to_i
            item = BlanksListingByItem.find_or_initialize_by(id: item_id)

            if item.new_record?
              created += 1
            else
              updated += 1
            end

            mult = row[3].to_f
            div = row[4].to_f
            item.update(mult: mult, div: div)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id = row[0].to_i
            item = Item.find_or_initialize_by(id: item_id)

            if item.new_record?
              created += 1
            else
              updated += 1
            end

            description = row[2]
            number_of_pcs_per_box = row[4].to_f
            ink_cost = row[5].to_f
            item.update(description: description, number_of_pcs_per_box: number_of_pcs_per_box, ink_cost: ink_cost)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            screen_id = row[0].to_i
            screen = Screen.find_or_initialize_by(id: screen_id)

            if screen.new_record?
              created += 1
            else
              updated += 1
            end

            cost = row[2].to_f
            screen.update(cost: cost)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            blank_id = row[0].to_i
            blank = Blank.find_or_initialize_by(id: blank_id)

            if blank.new_record?
              created += 1
            else
              updated += 1
            end

            blank_type_id = row[2]
            blank.update(blank_type_id: blank_type_id)
          end
        end

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

        xlsx.sheets.each do |sheet|
          current_sheet = xlsx.sheet(sheet)
          num_rows = current_sheet.last_row || 0

          2.upto(num_rows) do |i|
            row = current_sheet.row(i)
            item_id = row[0].to_i
            item = Item.find_or_initialize_by(id: item_id)

            if item.new_record?
              created += 1
            else
              updated += 1
            end

            item_type_id = row[2]
            item.update(item_type_id: item_type_id)
          end
        end

        render json: { message: "Your items were updated or created. Updated: #{updated}, Created: #{created}" }, status: :ok
      rescue => e
        Rails.logger.error "Error: #{e.message}"
        render json: { message: e.message }, status: :bad_request
      end

      # -------------------------
      # Download / Export actions
      # -------------------------
      def job_listing_download
        if !@database_location_exists
          @jobslisting = JobListing.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @jobslisting = JobWithScreenListing.filter_jobs_id_by_location(location_id)
        end

        respond_to do |format|
          format.xlsx { send_data JobListing.listing_xlsx(@jobslisting), filename: "1 - JOB LIST ACTUAL COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end

      def raw_materials
        if !@database_location_exists
          @raws = RawMaterial.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @raws = RawMaterialView.filter_raw_materials_by_location(location_id, nil)
        end

        respond_to do |format|
          format.xlsx { send_data RawMaterial.listing_xlsx(@raws), filename: "2 - NEW RAW CAL.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end

      def blanks_listing_item_with_cost_download
        if !@database_location_exists
          @blankslisting = BlanksListingItemWithCost.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @blankslisting = BlanksListingItemWithCost.filter_by_blanks_numbers_location(location_id, nil)
        end

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
        if !@database_location_exists
          @boxes = Box.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @boxes = BoxesLocationPrice.filter_boxes_id_by_location(location_id)
        end

        respond_to do |format|
          format.xlsx { send_data Box.listing_xlsx(@boxes), filename: "5 - BOX LIST FOR COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end

      def item_list_for_costing_module_download
        if !@database_location_exists
          @itemcostingmodule = Item.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @itemcostingmodule = ItemCostView.filter_items_id_by_location(location_id, nil)
        end

        respond_to do |format|
          format.xlsx { send_data ItemListForCostingModuleJob.listing_xlsx(@itemcostingmodule), filename: "6 - ITEM LIST FOR COSTING MODULE.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
        end
      end

      def screen_cliche_sizes_for_costing_module_download
        if !@database_location_exists
          @screens = Screen.all.order(:id)
        else
          location_id = @location ? @location.id : 0
          @screens = ScreensLocationPrice.filter_screens_id_by_location(location_id)
        end

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
          render json: { message: 'Your file is being processed.' }, status: :ok
        else
          render json: { message: document.errors.full_messages }, status: :bad_request
        end
      end

      def item_excel_report_download
        set_item
        if @item.present?
          item_json = render_to_string(template: "api/v1/items/show.json", status: status)
          @item = JSON.parse(item_json)

          respond_to do |format|
            format.xlsx { send_data ItemListForCostingModuleJob.show_item_xlsx(@item), filename: "item-report.xlsx", type: Mime::Type.lookup_by_extension(:xlsx) }
          end
        else
          render(json: { message: "item not found", status: :bad_request })
        end
      end

      def item_pdf_download
        set_item
        if @item.present?
          item_json = render_to_string(template: "api/v1/items/show.json", status: status)
          @item = JSON.parse(item_json)

          kit = PDFKit.new(to_item_html, page_size: 'A4')
          respond_to do |format|
            format.pdf { send_data kit.to_pdf, filename: "item-report.pdf", type: "application/pdf" }
          end
        else
          render(json: { message: "item not found", status: :bad_request })
        end
      end

      private

      def file_params
        params.permit(:file)
      end

      def to_cost_calculator_html
        render_to_string(template: 'api/v1/file/cost_calculator.html.erb', layout: false, disposition: 'inline', locals: { cost_data: @cost_data })
      end

      def to_item_html
        render_to_string(template: 'api/v1/file/item.html.erb', layout: false, disposition: 'inline', locals: { item: @item })
      end

      def set_item
        @item = Item.find_by(id: params[:id])
        return unless @item

        # add location id to jobs array
        @item.item_jobs.each do |item_job|
          item_job.location_id = @location ? @location.id : 0
        end

        # add location id to blanks_listing_item_with_cost array
        @item.blanks_listing_item_with_cost.each do |bliwc|
          bliwc.location_id = @location ? @location.id : 0
        end

        @item.location_id = @location ? @location.id : 0
        @ink_column_exists = ActiveRecord::Base.connection.column_exists?(:items, :ink_id) && @item.ink_id.present?
        @secondary_box_id_exists = ActiveRecord::Base.connection.column_exists?(:items, :secondary_box_id) && @item.secondary_box_id.present?
      end

      def get_current_year_db
        if ActiveRecord::Base.connection.table_exists? 'database_years'
            max_db_year = DatabaseYear.order('year DESC').first
            return max_db_year.year
            #DatabaseYear.maximum(:year) || Date.current.year.to_s
        end
        return Date.current.year.to_s
      end
      
      # This ensures @database_location_exists and @location are set after DB switch
      def prepare_location_and_year
        #current_year = get_current_year
        #req_year = request.headers['Database']
        #puts "Req DB : #{ActiveRecord::Base.connection.current_database}"
        #puts "Current DB : #{current_year}"
        
        connection_config = Rails.application.config.database_configuration[Rails.env]
        #database = ENV['PG_DB_PROD']
        current_year = get_current_year_db
        db_name = "costing_database_#{current_year}"
        connection_config['database'] = db_name
        ActiveRecord::Base.establish_connection(connection_config)
        # logger.debug "Selected database #{database}"
        # logger.debug "current_database #{ActiveRecord::Base.connection.current_database}"
            
        @database_location_exists = ActiveRecord::Base.connection.table_exists?('database_years')

        if @database_location_exists
          if request.headers['Location'].present? && request.headers['Location'] != 'null' && request.headers['Location'] != 'USA'
            @location = Location.find_by(name: request.headers['Location'])
          elsif params['location'].present? && params['location'] != 'USA'
            @location = Location.find_by(name: params['location'])
          end
        else
          @location = nil
        end
      rescue ActiveRecord::NoDatabaseError => e
        Rails.logger.error "Database not found: #{e.message}"
        @database_location_exists = false
        @location = nil
      end
    end
  end
end
