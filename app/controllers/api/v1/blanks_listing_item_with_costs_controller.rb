# frozen_string_literal: true
module Api
  module V1
    class BlanksListingItemWithCostsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blanks_listing_item_with_cost, only: [:show]
      after_action(only: [:index]) { set_pagination_header(ItemWithBlankPerCostView.count) }

      def index
        _start = params[:_start].to_i
        _end = params[:_end].to_i
        # @blanks_listing_item_with_cost = ItemWithBlankPerCostView.paginate(params.slice(:_end, :_sort, :_order))
        @blanks_listing_item_with_cost = ItemWithBlankPerCostView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @blanks_listing_item_with_cost = @blanks_listing_item_with_cost.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render json: @blanks_listing_item_with_cost, status: :ok
      end

      def show
        # TODO
        @item = Item.find(@blanks_listing_item_with_cost.item_number)
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
        @blanks_listing_by_item = BlanksListingByItem.where(item_number: params[:id], blank_number: params[:blank_number])
        if @blanks_listing_by_item.update(
            mult: params[:mult],
            div: params[:div]
        )
            # TODO
            @blanks_listing_by_item = BlanksListingByItem.where(item_number: params[:id])
            render json: @blanks_listing_by_item, status: :ok
        else
            render json: @blanks_listing_by_item.errors.messages, status: :bad_request
        end
      end

      def destroy
        params[:blanks].map do |row|
            if row[:deleted]
              BlanksListingItemWithCost.where(item_number: params[:id], blank_number: row[:blank_number]).destroy_all
            end
        end if params.has_key?(:blanks)

        # TODO
        @blanks_listing_item_with_cost = BlanksListingItemWithCost.where(item_number: params[:id])
        render json: @blanks_listing_item_with_cost, status: :ok
      end

      def update_item_blanks_with_cost_only
        logger.debug "item_blanks_with_costs_body #{params[:blanks]}"
        BlanksListingByItem.bulk_update_or_create(
          item_blanks_body(params[:blanks], params[:item_id]),
          :cell_key,
          key_as_id: false
        )
        BlanksListingItemWithCost.bulk_update_or_create(
          item_blanks_with_costs_body(params[:blanks], params[:item_id]),
          :cell_key,
          key_as_id: false
        )
        @blanks_listing_by_item = BlanksListingItemWithCost.where(item_number: params[:item_id])
        render json: @blanks_listing_by_item, status: :ok
      end

      private

      def render_item_and_item_blanks_template(template_name: :index, status: :ok)
        render template: "api/v1/item_blanks_with_cost/#{template_name.to_s}.json", status: status
      end

      def item_blanks_body(blanks, item_id)
        blanks.map! do |row|
          blanks = row[:blank_number].to_i
          Hash[
            :blank_number, row[:blank_number],
            :item_number, item_id.to_s,
            :mult, row[:mult].to_i,
            :div, row[:div].to_i,
            :cell_key, item_id.to_s + row[:blank_number].to_s
          ]
        end
      end

      def item_blanks_with_costs_body(blanks, item_id)
        blanks.map! do |row|
          blanks = row[:blank_number].to_i
          Hash[
            :blank_number, row[:blank_number],
            :item_number, item_id.to_s,
            :cell_key, item_id.to_s + row[:blank_number].to_s
          ]
        end
      end

      def blanks_listing_item_with_cost_params
        params.require(:blanks_listing_item_with_cost).permit(:id, :item_number, :blank_number, :cost_per_blank, :mult, :div)
      end

      def set_blanks_listing_item_with_cost
        @blanks_listing_item_with_cost = BlanksListingItemWithCost.find(params[:id])
      end
    end
  end
end
