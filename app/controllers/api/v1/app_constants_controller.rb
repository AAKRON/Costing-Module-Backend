# frozen_string_literal: true
module Api
  module V1
    class Api::V1::AppConstantsController < BaseController
      before_action :restrict_access
      before_action :set_app_constant, only: :update
      #after_action only: [:index] { set_pagination_header(AppConstant.count) }

      def index
        #set_pagination_header(AppConstant.count)
        @app_constants = AppConstant.paginate(params.slice(:_end, :_sort, :_order))
        @app_constants = @app_constants.search(params[:q], :name) unless params.fetch(:q, '').empty?
        render json: @app_constants, status: 200
      end

      def create
        @app_constant = AppConstant.new(app_constant_params)

        if @app_constant.save
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
        if @app_constant.update(app_constant_params)
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
      end
    end
  end
end
