# frozen_string_literal: true
module Api
  module V1
    class BlanksListingItemWithCostsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blanks_listing_item_with_cost, only: [:show, :update, :destroy]
      after_action (only: [:index]) { set_pagination_header(ItemWithBlankPerCostView.count) }

      def index
        @blanks_listing_item_with_cost = ItemWithBlankPerCostView.paginate(params.slice(:_end, :_sort, :_order))
        @blanks_listing_item_with_cost = @blanks_listing_item_with_cost.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render json: @blanks_listing_item_with_cost, status: :ok
      end

      def show
        render json: @blanks_listing_item_with_cost, status: :ok
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

      private

      def blanks_listing_item_with_cost_params
        params.require(:blanks_listing_item_with_cost).permit(:id, :item_number, :blank_number, :cost_per_blank)
      end

      def set_blanks_listing_item_with_cost
        @blanks_listing_item_with_cost = BlanksListingItemWithCost.find(params[:id])
      end
    end
  end
end
