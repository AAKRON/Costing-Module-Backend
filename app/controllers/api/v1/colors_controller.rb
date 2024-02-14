# frozen_string_literal: true
module Api
  module V1
    class ColorsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_color, only: %i[update show]
      after_action(only: [:index]) { set_pagination_header(Color.count) }
      after_action(only: [:color_list_only]) { set_pagination_header(Color.count) }

      def index
        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0

        color = ColorsView.filter_by_location(_location_id, _order, _start, _limit, params)
        render json: color, status: :ok
      end

      def create
        @color = Color.new(color_params)
        if @color.save
          update_or_create_location_prices # location prices
          render json: @color, status: :created
        else
          render json: @color.errors, status: :bad_request
        end
      end

      def update
        @color = Color.find_by_id!(params[:id])
        color_params = update_or_create_location_prices # location prices
        if @color.update(color_params)
          set_color # update location prices
          render json: @color, status: :ok
        else
          render json: @color.errors, status: :bad_request
        end
      end

      def show
        render json: @color, status: :ok
      end

      def destroy
        ColorsLocationPrice.where(colors_id: params[:id]).first.try(:destroy)
        Color.find(params[:id]).destroy
        head :no_content
      end

      def color_list_only
        @color = Color.all
        render json: @color, status: :ok
      end

      private

      def color_params
        params.permit(:name, :code, :cost_of_color)
      end

      def set_color
        @color = Color.find_by_id!(params[:id])

        # Add location prices if exist
        if @location.present?
            @colors_location = ColorsLocationPrice.where(colors_id: params[:id]).where(locations_id: @location[:id]).first
            if @colors_location.present?
                @color[:cost_of_color] = @colors_location[:cost_of_color]
            end
        end
      end

      def update_or_create_location_prices
        if @location.present?
            if @colors_location.present?
                @colors_location.update(cost_of_color: params[:cost_of_color])
            else
                @colors_location = ColorsLocationPrice.new(cost_of_color: params[:cost_of_color], locations_id: @location[:id], colors_id: @color[:id])
                @colors_location.save
            end
            # Keep params that are not prices
            return params.require(:color).permit(:name, :code)
        else
            return color_params  # Keep all params if there are no location
        end
      end
    end
  end
end
