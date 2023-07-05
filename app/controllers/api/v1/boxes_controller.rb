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
        @boxes = Box.paginate(params.slice(:_end, :_sort, :_order))
        @boxes = @boxes.search(params[:q], :name) unless params.fetch(:q, '').empty?
        @boxes = @boxes.search(params[:price], :cost_per_box) unless params.fetch(:price, '').empty?
        @boxes = @boxes.search(params[:id], :id) unless params.fetch(:id, '').empty?
        

        render template: 'api/v1/box/index.json', status: :ok
      end

      def create
        @box = Box.new(box_params)
        if @box.save
          render template: 'api/v1/box/show.json', status: 201
        else
          render json: @box.errors, status: :bad_request
        end
      end

      def update
        @box = Box.find(params[:id])
        if @box.update(box_params)
          render json: @box, status: :ok
        else
          render json: @box.errors, status: :bad_request
        end
      end

      def show
        @box = Box.find(params[:id])

        render template: 'api/v1/box/show.json', status: 201
      end

      def destroy
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
      end
      def box_params
        params.permit(:name, :cost_per_box)
      end
    end
  end
end
