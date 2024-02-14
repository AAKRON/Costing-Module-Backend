# frozen_string_literal: true
module Api
  module V1
    class BoxesController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_box, only: [:show, :update, :destroy]
      after_action(only: [:index]) { set_pagination_header(Box.count) }
      after_action(only: [:box_list_only]) { set_pagination_header(Box.count) }

      def index
        id = (params.fetch(:id, '') == 'null' ) ? '' : params.fetch(:id, '')
        cost_per_box = (params.fetch(:cost_per_box, '') == 'null' ) ? '' : params.fetch(:cost_per_box, '')
        name = params.fetch(:box_name, '')

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0
        @boxes = BoxesLocationPrice.filter_by_location(_location_id, _order, _start, _limit, id, cost_per_box, name)

        render template: 'api/v1/box/index.json', status: :ok
      end

      def create
        @box = Box.new(box_params)
        if @box.save
          update_or_create_location_prices # location prices
          render template: 'api/v1/box/show.json', status: 201
        else
          render json: @box.errors, status: :bad_request
        end
      end

      def update
        @box = Box.find(params[:id])
        box_params = update_or_create_location_prices # location prices
        if @box.update(box_params)
          set_box # update location prices
          render json: @box, status: :ok
        else
          render json: @box.errors, status: :bad_request
        end
      end

      def show
        render json: @box, status: :ok
      end

      def destroy
        @BoxesLocationPrice.where(boxes_id: params[:id]).first.try(:destroy)
        Box.find(params[:id]).destroy
        head :no_content
      end

      def box_list_only
        @boxes = Box.all
        render json: @boxes, status: :ok
      end

      private

      def set_box
            @box = Box.find(params[:id])

            # Add location prices if exist
            if @location.present?
                @boxes_location = BoxesLocationPrice.where(boxes_id: params[:id]).where(locations_id: @location[:id]).first
                if @boxes_location.present?
                    @box[:cost_per_box] = @boxes_location[:cost_per_box]
                end
            end
      end

      def box_params
        params.permit(:name, :cost_per_box)
      end

      def update_or_create_location_prices
        if @location.present?
            if @boxes_location.present?
                @boxes_location.update(cost_per_box: params[:cost_per_box])
            else
                @boxes_location = BoxesLocationPrice.new(cost_per_box: params[:cost_per_box], locations_id: @location[:id], boxes_id: @box[:id])
                @boxes_location.save
            end
            # Keep params that are not prices
            return params.permit(:name)
        else
            return box_params  # Keep all params if there are no location
        end
      end
    end
  end
end
