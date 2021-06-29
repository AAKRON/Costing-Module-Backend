# frozen_string_literal: true
module Api
  module V1
    class BlanksListingByItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blanks_listing_by_item, only: [:show, :update, :destroy]
      #after_action only: [:index] { set_pagination_header(BlanksListingByItem.count) }
	  ##after_action :set_pagination_header(BlanksListingByItem.count), only: [:index]
      
      def index
        @blanks_listing_by_item = BlanksListingByItem.paginate(params.slice(:_end, :_sort, :_order))
        @blanks_listing_by_item = @blanks_listing_by_item.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render json: @blanks_listing_by_item, status: :ok
      end

      def show
        render json: @blanks_listing_by_item, status: :ok
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

      private

      def blanks_listing_by_item_params
        params.require(:blanks_listing_by_item).permit(:id, :item_number, :blank_number, :mult, :div)
      end

      def set_blanks_listing_by_item
        @blanks_listing_by_item = BlanksListingByItem.find(params[:id])
      end
    end
  end
end
