# frozen_string_literal: true
module Api
  module V1
    class RawMaterialsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_raw_material, only: [:show, :update, :destroy]
      #after_action only: [:index] { set_pagination_header(RawMaterialView.count(1)) }
      #after_action only: [:raw_material_list_only] { set_pagination_header(RawMaterial.count) }

      def index
        set_pagination_header(RawMaterialView.count(1))
        @raw_materials = RawMaterialView.paginate(params.slice(:_end, :_sort, :_order))
        @raw_materials = @raw_materials.search(params[:q], :name) unless params.fetch(:q, '').empty?
      end

      def create
        @raw_material = RawMaterial.new(raw_material_params)
        if @raw_material.save
          render json: @raw_material, status: :created
        else
          render json: @raw_material.errors, status: :not_ok
        end
      end

      def show
        render json: @raw_material, status: :ok
      end

      def edit
      end

      def destroy
        @raw_material.destroy
      end

      def update
        if @raw_material.update(raw_material_params)
          render json: @raw_material, status: 201
        else
          render json: @raw_material.errors, status: :bad_request
        end
      end

      def raw_material_list_only
        set_pagination_header(RawMaterial.count)
        @raw_material = RawMaterial.all

        render json: @raw_material, status: :ok
      end

      private

      def raw_material_params
        params.permit(:name, :cost, :units_of_measure_id, :color_id, :vendor_id, :rawmaterialtype_id)
      end

      def set_raw_material
        @raw_material = RawMaterial.find(params[:id])
      end
    end
  end
end
