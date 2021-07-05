# frozen_string_literal: true
module Api
  module V1
    class BlankTypesController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blank_type, only: [:update, :show]
      after_action(only: [:index]) { set_pagination_header(BlankType.count) }

      def index
        #set_pagination_header(BlankType.count)
        
        @blank_types = BlankType.paginate(params.slice(:_end, :_sort, :_order))
        @blank_types = @blank_types.search(params[:q], :type_number) unless params.fetch(:q, '').empty?

        render json: @blank_types, status: :ok
      end

      def create
        @blank_type = BlankType.new(blank_params)

        if @blank_type.save
          render json: @blank_type, status: 201
        else
          render json: @blank_type.errors, status: 400
        end
      end

      def show
        render json: @blank_type, status: :ok
      end

      def update
        if @blank_type.update(blank_params)
          render json: @blank_type, status: :ok
        else
          render json: @blank_type.errors.messages, status: :bad_request
        end
      end

      def destroy
        BlankType.find_by_id!(params[:id]).destroy
      end

      private

      def blank_params
        params.require(:blank_type).permit(:id, :type_number, :description)
      end

      def set_blank_type
        @blank_type = BlankType.find(params[:id])
      end
    end
  end
end
