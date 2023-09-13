# frozen_string_literal: true
module Api
  module V1
    class ItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_item, only: [:show, :update, :update_type]
      after_action(only: [:index]) { set_pagination_header(ItemCostView.count) }
      after_action(only: [:item_list_only]) { set_pagination_header(Item.count) }

      def index
        #set_pagination_header(ItemCostView.count)
        item_id = (params.fetch(:item_id, '') == 'null' ) ? '' : params.fetch(:item_id, '')
        ink_cost = (params.fetch(:ink_cost, '') == 'null' ) ? '' : params.fetch(:ink_cost, '')
        box_cost = (params.fetch(:box_cost, '') == 'null' ) ? '' : params.fetch(:box_cost, '')
        total_price_cost = (params.fetch(:total_price_cost, '') == 'null' ) ? '' : params.fetch(:total_price_cost, '')
        total_inventory_cost = (params.fetch(:total_inventory_cost, '') == 'null' ) ? '' : params.fetch(:total_inventory_cost, '')

        _start = params[:_start].to_i
        _end = params[:_end].to_i
        # @items = ItemCostView.paginate(params.slice(:_end, :_sort, :_order))
        @items = ItemCostView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @items = @items.search(item_id, :item_number) unless item_id.empty?
        @items = @items.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @items = @items.search(params[:type_description], :type_description) unless params.fetch(:type_description, '').empty?
        @items = @items.where("lower(box_name) LIKE ?", "%#{params[:box_name]}%") unless params.fetch(:box_name, '').empty?
        @items = @items.where("number_of_pcs_per_box = #{params[:number_of_pcs_per_box]}") unless params.fetch(:number_of_pcs_per_box, '').empty?
        @items = @items.search(ink_cost, :ink_cost) unless ink_cost.empty?
        @items = @items.search(box_cost, :box_cost) unless box_cost.empty?
        @items = @items.search(total_price_cost, :total_price_cost) unless total_price_cost.empty?
        @items = @items.search(total_inventory_cost, :total_inventory_cost) unless total_inventory_cost.empty?

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

      def update_type
        if params[:apikey] != "Aakron2023$"
          render json: { message: 'Not Authorized' }, status: 401
        else
          if @item.present?
            @item_type = ItemType.where("description = ?", "#{params[:item_type]}").first

            if @item_type.present?
              @item.update(item_type_id: @item_type.type_number)
              render json: {"item": @item, "item_type": @item_type}, status: :ok
            else
              render(json: { message: "ItemType not found", status: :bad_request })
            end
          else
            render(json: { message: "item not found", status: :bad_request })
          end
        end
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
