# frozen_string_literal: true
module Api
  module V1
    class ItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_item, only: [:show, :update]
      after_action(only: [:index]) { set_pagination_header(ItemCostView.count) }
      after_action(only: [:item_list_only]) { set_pagination_header(Item.count) }

      def index
        #set_pagination_header(ItemCostView.count)
        @items = ItemCostView.paginate(params.slice(:_end, :_sort, :_order))
        @items = @items.search(params[:q], :item_number) unless params.fetch(:q, '').empty?
        @items = @items.where("description LIKE ?", "%#{params[:description]}%") unless params.fetch(:description, '').empty?
        @items = @items.where("type_description LIKE ?", "%#{params[:type_description]}%") unless params.fetch(:type_description, '').empty?
        @items = @items.where("lower(box_name) LIKE ?", "%#{params[:box_name]}%") unless params.fetch(:box_name, '').empty?
        @items = @items.where("number_of_pcs_per_box = #{params[:number_of_pcs_per_box]}") unless params.fetch(:number_of_pcs_per_box, '').empty?
        @items = @items.where("ink_cost = #{params[:ink_cost]}") unless params.fetch(:ink_cost, '').empty?
        @items = @items.where("box_cost = #{params[:box_cost]}") unless params.fetch(:box_cost, '').empty?
        @items = @items.where("total_price_cost = #{params[:total_price_cost]}") unless params.fetch(:total_price_cost, '').empty?
        @items = @items.where("total_inventory_cost = #{params[:total_inventory_cost]}") unless params.fetch(:total_inventory_cost, '').empty?

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
        #set_pagination_header(Item.count)
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
