# frozen_string_literal: true
module Api
  module V1
    class ColorsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      after_action only: [:index, :color_list_only] { set_pagination_header(Color.count) }

      def index
        color = Color.all.paginate(params.slice(:_end, :_sort, :_order))
        color = color.search(params[:q], :name) unless params.fetch(:q, '').empty?

        render json: color, status: :ok
      end

      def create
        color = Color.new(color_params)
        if color.save
          render json: color, status: :created
        else
          render json: color.errors, status: :bad_request
        end
      end

      def update
        color = Color.find(params[:id])
        if color.update(color_params)
          render json: color, status: :ok
        else
          render json: color.errors, status: :bad_request
        end
      end

      def show
        color = Color.find(params[:id])

        render json: color, status: :ok
      end

      def destroy
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
    end
  end
end
