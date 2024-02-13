# frozen_string_literal: true
module Api
  module V1
    class ScreensController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_screen, only: [:show, :update, :destroy]
      after_action(only: [:index]) { set_pagination_header(Screen.count) }

      def index
        id = (params.fetch(:id, '') == 'null' ) ? '' : params.fetch(:id, '')
        screen_id = (params.fetch(:screen_id, '') == 'null' ) ? '' : params.fetch(:screen_id, '')
        cost = (params.fetch(:cost, '') == 'null' ) ? '' : params.fetch(:cost, '')

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0
        @screens = ScreensLocationPrice.filter_by_location(_location_id, _order, _start, _limit, id, cost, screen_id)

        render template: 'api/v1/screens/index.json', status: :ok
      end

      def create
        @screen = Screen.new(screen_params)
        update_or_create_location_prices # location prices
        if @screen.save
          render json: @screen, status: 201
        else
          render json: @screen.errors, status: 400
        end
      end

      def update
        @screen = Screen.find(params[:id])
        screen_params = update_or_create_location_prices # location prices
        if @screen.update(screen_params)
          set_screen
          render template: 'api/v1/screens/show.json', status: 201
        else
          render json: @screen.errors, status: 400
        end
      end

      def destroy
        @screens_location.destroy
        @screen.destroy
        render json: "deleted successfully", status: :no_content
      end

      def show
        render json: @screen, status: :ok
      end

      private

      def screen_params
        params.require(:screen).permit(:id, :screen_size, :cost)
      end

      def set_screen
        @screen = Screen.find(params[:id])

        # Add location prices if exist
        if @location.present?
            @screens_location = ScreensLocationPrice.where(screens_id: params[:id]).where(locations_id: @location[:id]).first
            if @screens_location.present?
                @screen[:cost] = @screens_location[:cost]
            end
        end

        def update_or_create_location_prices
            if @location.present?
                if @screens_location.present?
                    @screens_location.update(cost: params[:cost])
                else
                    @screens_location = ScreensLocationPrice.new(cost: params[:cost], locations_id: @location[:id], screens_id: @screen[:id])
                    @screens_location.save
                end
                # Keep params that are not prices
                return params.require(:screen).permit(:id, :screen_size)
            else
                return screen_params  # Keep all params if there are no location
            end
        end
      end
    end
  end
end
