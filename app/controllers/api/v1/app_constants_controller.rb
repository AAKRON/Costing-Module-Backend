# frozen_string_literal: true
module Api
  module V1
    class Api::V1::AppConstantsController < BaseController
      before_action :restrict_access
      before_action :set_app_constant, only: %i[update show]
      after_action(only: [:index]) { set_pagination_header(AppConstant.count) }

      def index
        _location_id = @location ? @location.id : 0
        @app_constants = AppConstantsView.filter_by_location(_location_id, params)
        render json: @app_constants, status: 200
      end

      def create
        @app_constant = AppConstant.new(app_constant_params)

        if @app_constant.save
            update_or_create_location_prices # location prices
            render json: @app_constant, status: 201
        else
          render json: @app_constant.errors, status: 400
        end
      end

      def show
        @app_constant = AppConstant.find(params[:id])

        render json: @app_constant, status: 201
      end

      def update
        @app_constant = AppConstant.find(params[:id])
        app_constant_params = update_or_create_location_prices # location prices
        if @app_constant.update(app_constant_params)
            set_app_constant # update location prices
            render json: @app_constant, status: 201
        else
          render json: @app_constant.errors, status: 400
        end
      end

      def destroy
        @app_constant = AppConstant.find(params[:id])
        @app_constant.destroy

        render json: "deleted successfully", status: :no_content
      end

      private

      def app_constant_params
        params.permit(:id, :name, :value)
      end

      def set_app_constant
        @app_constant = AppConstant.find(params[:id])

        # Add location prices if exist
        if @location.present?
            @app_constants_location = AppConstantsLocationPrice.where(app_constants_id: params[:id]).where(locations_id: @location[:id]).first
            if @app_constants_location.present?
                @app_constant[:value] = @app_constants_location[:value]
            end
        end
      end

      def update_or_create_location_prices
        if @location.present?
            if @app_constants_location.present?
                @app_constants_location.update(value: params[:value])
            else
                @app_constants_location = AppConstantsLocationPrice.new(value: params[:value], locations_id: @location[:id], app_constants_id: @app_constant[:id])
                @app_constants_location.save
            end
            # Keep params that are not prices
            return params.require(:app_constant).permit(:id, :name)
        else
            return app_constant_params  # Keep all params if there are no location
        end
      end
    end
  end
end