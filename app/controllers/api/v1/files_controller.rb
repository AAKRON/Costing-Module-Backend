# frozen_string_literal: true
require "pdfkit"
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
