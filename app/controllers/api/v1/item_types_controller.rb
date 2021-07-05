# frozen_string_literal: true
module Api
  module V1
    class ItemTypesController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_item_type, only: [:update, :show]
      after_action (only: [:index]) { set_pagination_header(ItemType.count) }
      after_action (only: [:item_type_list_only]) { set_pagination_header(ItemType.count) }

      def index
        #set_pagination_header(ItemType.count)
        @item_types = ItemType.paginate(params.slice(:_end, :_sort, :_order))
        @item_types = @item_types.search(params[:q], :type_number) unless params.fetch(:q, '').empty?

        render json: @item_types, status: :ok
      end

      def create
        @item_type = ItemType.new(item_params)

        if @item_type.save
          render json: @item_type, status: 201
        else
          render json: @item_type.errors, status: 400
        end
      end

      def show
        render json: @item_type, status: :ok
      end

      def update
        if @item_type.update(item_params)
          render json: @item_type, status: :ok
        else
          render json: @item_type.errors.messages, status: :bad_request
        end
      end

      def item_type_list_only
        #set_pagination_header(ItemType.count)
        @item_type = ItemType.all

        render json: @item_type, status: :ok
      end

      def destroy
        ItemType.find_by_id!(params[:id]).destroy
      end

      private

      def item_params
        params.require(:item_type).permit(:id, :type_number, :description)
      end

      def set_item_type
        @item_type = ItemType.find(params[:id])
      end
    end
  end
end
