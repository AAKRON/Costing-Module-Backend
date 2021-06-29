# frozen_string_literal: true
module Api
  module V1
    class ItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_item, only: [:show, :update]
      #after_action only: [:index] { set_pagination_header(ItemCostView.count) }
      ##after_action :set_pagination_header(ItemCostView.count), only: [:index]
      #after_action only: [:item_list_only] { set_pagination_header(Item.count) }
      ##after_action :set_pagination_header(Item.count), only: [:item_list_only]

      def index
        @items = ItemCostView.paginate(params.slice(:_end, :_sort, :_order))
        @items = @items.search(params[:q], :item_number) unless params.fetch(:q, '').empty?

        render_items_template(template_name: :list, status: :ok)
      end

      def show
        render_items_template(template_name: __method__, status: :ok)
      end

      def create
        @item = Item.new(item_params)

        if @item.save
          render json: @item, status: 201
        else
          render json: @item.errors, status: 400
        end
      end

      def update
        if @item.update(item_params)
          render json: @item, status: :ok
        else
          render json: @item.errors.messages, status: :bad_request
        end
      end

      def destroy
        Item.find(params[:id]).destroy
      end

      def item_list_only
        @items = Item.all

        render json: @items, status: :ok
      end
      private

      def item_params
        params.require(:item).permit(:item_number, :description, :box_id, :item_type_id, :number_of_pcs_per_box, :ink_cost)
      end

      def set_item
        @item = Item.find(params[:id])
      end

      def render_items_template(template_name: :index, status: :ok)
        render template: "api/v1/items/#{template_name.to_s}.json", status: status
      end
    end
  end
end
