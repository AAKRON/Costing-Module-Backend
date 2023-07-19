# frozen_string_literal: true
module Api
  module V1
    class BlanksListingItemWithCostsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blanks_listing_item_with_cost, only: [:update, :destroy]
      after_action(only: [:index]) { set_pagination_header(ItemWithBlankPerCostView.count) }

      def index
        @blanks_listing_item_with_cost = ItemWithBlankPerCostView.paginate(params.slice(:_end, :_sort, :_order))
        @blanks_listing_item_with_cost = @blanks_listing_item_with_cost.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render json: @blanks_listing_item_with_cost, status: :ok
      end

      def show
        @item = Item.find(params[:id])
        render_item_and_item_blanks_template(template_name: __method__, status: :ok)
      end

      def create
        @blanks_listing_item_with_cost = BlanksListingItemWithCost.new(blanks_listing_item_with_cost_params)

        if @blanks_listing_item_with_cost.save
          render json: @blanks_listing_item_with_cost, status: 201
        else
          render json: @blanks_listing_item_with_cost.errors, status: 400
        end
      end

      def update
        if @blanks_listing_item_with_cost.update(blanks_listing_item_with_cost_params)
          render json: @blanks_listing_item_with_cost, status: 201
        else
          render json: @blanks_listing_item_with_cost.errors, status: 400
        end
      end

      def destroy
        @blanks_listing_item_with_cost.destroy

        render json: "deleted successfully", status: :no_content
      end

      # # TODO: Update and finish it
      # def update_item_blanks_with_cost_only
      #   BlanksListingByItem.bulk_update_or_create(
      #     item_blanks_body(params[:blanks], params[:item_id]),
      #     :cell_key,
      #     key_as_id: false
      #   )
      #   @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])
      #   render json: @blanks_listing_by_item, status: :ok
      # end

      # def update_item_blanks_with_cost_data
      #   @item = Item.find(params[:id])

      #   if @item.present?
      #     @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])
      #     if @blanks_listing_by_item
      #       @blanks_listing_by_item.update(
      #         job_listing_id: params[:job_listing_id],
      #         hour_per_piece:params[:hour_per_piece]
      #       )
      #       @blanks_listing_by_item = BlanksListingByItem.find(params[:blanks_item_id])

      #       render json: @blanks_listing_by_item, status: :ok
      #     else
      #       render json: @blanks_listing_by_item.errors.messages, status: :bad_request
      #     end
      #   else
      #     render(json: { message: "item not found",status: :bad_request })
      #   end
      # end

      private

      def render_item_and_item_blanks_template(template_name: :index, status: :ok)
        render template: "api/v1/item_blanks/#{template_name.to_s}.json", status: status
      end

      def blanks_listing_item_with_cost_params
        params.require(:blanks_listing_item_with_cost).permit(:id, :item_number, :blank_number, :cost_per_blank)
      end

      def set_blanks_listing_item_with_cost
        @blanks_listing_item_with_cost = BlanksListingItemWithCost.find(params[:id])
      end
    end
  end
end
