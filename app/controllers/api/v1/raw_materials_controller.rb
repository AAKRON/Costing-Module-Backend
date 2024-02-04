# frozen_string_literal: true
module Api
  module V1
    class RawMaterialsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_raw_material, only: [:show, :update, :destroy]
      after_action(only: [:index]) { set_pagination_header(RawMaterialView.count(1)) }
      after_action(only: [:raw_material_list_only]) { set_pagination_header(RawMaterial.count) }

      def index
        cost = (params.fetch(:cost, '') == 'null' ) ? '' : params.fetch(:cost, '')
        name = params.fetch(:name, '')
        raw_material_type = params.fetch(:raw_material_type, '')
        vendor = params.fetch(:vendor, '')
        unit = params.fetch(:unit, '')
        color = params.fetch(:color, '')

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0

        @raw_materials = RawMaterialView.filter_by_location(_location_id, _order, _start, _limit, cost, name, raw_material_type, vendor, unit, color)
      end

      def create
        @raw_material = RawMaterial.new(raw_material_params)
        if @raw_material.save
          update_or_create_location_prices # location prices
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
        @raw_material = RawMaterial.find(params[:id])
        raw_material_params = update_or_create_location_prices # location prices
        if @raw_material.update(raw_material_params)
          set_raw_material # update location prices
          render json: @raw_material, status: 201
        else
          render json: @raw_material.errors, status: :bad_request
        end
      end

      def raw_material_list_only
        #set_pagination_header(RawMaterial.count)
        @raw_material = RawMaterial.all

        render json: @raw_material, status: :ok
      end

      private

      def raw_material_params
        params.permit(:name, :cost, :units_of_measure_id, :color_id, :vendor_id, :rawmaterialtype_id)
      end

      def set_raw_material
        @raw_material = RawMaterial.find(params[:id])

        # Add location prices if exist
        if @location.present?
            @raw_materials_location = RawMaterialsLocationPrice.where(raw_materials_id: params[:id]).where(locations_id: @location[:id]).first
            if @raw_materials_location.present?
                @raw_material[:cost] = @raw_materials_location[:cost]
            end
        end
      end

      def update_or_create_location_prices
        if @location.present?
            @raw_materials_location = RawMaterialsLocationPrice.where(raw_materials_id: params[:id]).where(locations_id: @location[:id]).first
            if @raw_materials_location.present?
                @raw_materials_location.update(cost: params[:cost])
            else
                @raw_materials_location = RawMaterialsLocationPrice.new(cost: params[:cost], locations_id: @location[:id], raw_materials_id: @raw_material[:id])
                @raw_materials_location.save
            end
            # Keep params that are not prices
            return params.permit(:name, :units_of_measure_id, :color_id, :vendor_id, :rawmaterialtype_id)
        else
            return raw_material_params  # Keep all params if there are no location
        end
      end
    end
  end
end
