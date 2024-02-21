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
        item_number = (params.fetch(:item_id, '') == 'null' ) ? '' : params.fetch(:item_id, '')
        description = params.fetch(:description, '')
        type_description = params.fetch(:type_description, '')
        box_name = params.fetch(:box_name, '')
        number_of_pcs_per_box = params.fetch(:number_of_pcs_per_box, '')
        ink_cost = (params.fetch(:ink_cost, '') == 'null' ) ? '' : params.fetch(:ink_cost, '')
        box_cost = (params.fetch(:box_cost, '') == 'null' ) ? '' : params.fetch(:box_cost, '')
        secondary_box_cost = (params.fetch(:secondary_box_cost, '') == 'null' ) ? '' : params.fetch(:secondary_box_cost, '')
        total_price_cost = (params.fetch(:total_price_cost, '') == 'null' ) ? '' : params.fetch(:total_price_cost, '')
        total_inventory_cost = (params.fetch(:total_inventory_cost, '') == 'null' ) ? '' : params.fetch(:total_inventory_cost, '')
        @secondary_box_id_exists = ActiveRecord::Base.connection.column_exists?(:items, :secondary_box_id)

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0

        @items = ItemCostView.filter_by_location(_location_id, _order, _start, _limit, item_number, description, type_description, box_name, number_of_pcs_per_box, ink_cost, box_cost, @secondary_box_id_exists, secondary_box_cost, total_price_cost, total_inventory_cost)
        render_items_template(template_name: :list, status: :ok)
      end

      def show
        # add location id to jobs array
        @item.item_jobs.map do |item_job|
            item_job.location_id = @location ? @location.id : 0
        end

        # add location id to blanks_listing_item_with_cost array
        @item.blanks_listing_item_with_cost.map do |blanks_listing_item_with_cost|
            blanks_listing_item_with_cost.location_id = @location ? @location.id : 0
        end

        @item.location_id = @location ? @location.id : 0

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
        if @item.update(item_update_params)
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
        params.require(:item).permit(:item_number, :description, :box_id, :secondary_box_id, :number_of_pcs_per_secondary_box, :item_type_id, :number_of_pcs_per_box, :ink_id)
      end

      def item_update_params
        params.require(:item).permit(:description, :box_id, :secondary_box_id, :number_of_pcs_per_secondary_box, :item_type_id, :number_of_pcs_per_box, :ink_id)
      end

      def set_item
        @item = Item.find(params[:id])
        @ink_column_exists = ActiveRecord::Base.connection.column_exists?(:items, :ink_id) && @item.ink_id.present?
        @secondary_box_id_exists = ActiveRecord::Base.connection.column_exists?(:items, :secondary_box_id) && @item.secondary_box_id.present?
      end

      def render_items_template(template_name: :index, status: :ok)
        render template: "api/v1/items/#{template_name.to_s}.json", status: status
      end
    end
  end
end
