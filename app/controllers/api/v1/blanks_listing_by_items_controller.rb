# frozen_string_literal: true
module Api
  module V1
    class BlanksListingByItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blanks_listing_by_item, only: [:show, :update, :destroy]
      after_action(only: [:index]) { set_pagination_header(BlanksListingByItem.count) }

      def index
        @blanks_listing_by_item = BlanksListingByItem.paginate(params.slice(:_end, :_sort, :_order))
        @blanks_listing_by_item = @blanks_listing_by_item.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render json: @blanks_listing_by_item, status: :ok
      end

      def show
        @item = Item.find(@blanks_listing_by_item.item_number)
        render_item_and_item_blanks_template(template_name: __method__, status: :ok)
      end

      def create
        @blanks_listing_by_item = BlanksListingByItem.new(blanks_listing_by_item_params)

        if @blanks_listing_by_item.save
          render json: @blanks_listing_by_item, status: 201
        else
          render json: @blanks_listing_by_item.errors, status: 400
        end
      end

      def update
        if @blanks_listing_by_item.update(blanks_listing_by_item_params)
          render json: @blanks_listing_by_item, status: 201
        else
          render json: @blanks_listing_by_item.errors, status: 400
        end
      end

      def destroy
        @blanks_listing_by_item.destroy

        render json: "deleted successfully", status: :no_content
      end

      # TODO: Update and finish it
      def update_item_blanks_only
        BlanksListingByItem.bulk_update_or_create(
          item_blanks_body(params[:blanks], params[:item_id]),
          :cell_key,
          key_as_id: false
        )
        @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])
        render json: @blanks_listing_by_item, status: :ok
      end

      def update_item_blanks_data
        @item = Item.find(params[:id])

        if @item.present?
          @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])
          if @blanks_listing_by_item
            @blanks_listing_by_item.update(
              blank_number: params[:blank_number],
              hour_per_piece:params[:hour_per_piece]
            )
            @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])

            render json: @blanks_listing_by_item, status: :ok
          else
            render json: @blanks_listing_by_item.errors.messages, status: :bad_request
          end
        else
          render(json: { message: "item not found",status: :bad_request })
        end
      end

      private

      def blanks_listing_by_item_params
        params.require(:blanks_listing_by_item).permit(:id, :item_number, :blank_number, :mult, :div)
      end

      def set_blanks_listing_by_item
        @blanks_listing_by_item = BlanksListingByItem.find(params[:id])
      end

      def render_item_and_item_blanks_template(template_name: :index, status: :ok)
        render template: "api/v1/item_blanks/#{template_name.to_s}.json", status: status
      end

      # TODO: Update and finish it
      def item_blanks_body(jobs, blank_number)
        # jobs.map! do |row|
        #   job_number = row[:job_listing_id].to_i
        #   Hash[:hour_per_piece, row[:hour_per_piece].to_f, :blank_id, params[:blank_number],
        #          :job_listing_id, job_number, :cell_key, job_number.to_s + blank_number.to_s
        #   ]
        # end
      end

    end
  end
end
