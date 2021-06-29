module Api
  module V1
    class RawmaterialtypesController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_raw_material_type, only: [:show, :update, :destroy]
      #after_action only: [:index, :raw_material_type_list_only] { set_pagination_header(Rawmaterialtype.count) }
	  ##after_action :set_pagination_header(Rawmaterialtype.count), only: [:index, :raw_material_type_list_only]	
      def index
        @raw_material_types = Rawmaterialtype.all.paginate(params.slice(:_end, :_sort, :_order))
        @raw_material_types = @raw_material_types.search(params[:q], :name) unless params.fetch(:q, '').empty?
        render json: @raw_material_types, status: :ok
      end

      def show
        render json: @raw_material_type, status: :ok
      end

      def create
        @raw_material_type = Rawmaterialtype.new(raw_material_type_params)

        if @raw_material_type.save
          render json: @raw_material_type, status: :created
        else
          render json: @raw_material_type.errors, status: :unprocessable_entity
        end
      end

      def update
        if @raw_material_type.update(raw_material_type_params)
          render json: @raw_material_type, status: :ok
        else
          render json: @raw_material_type.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @raw_material_type.destroy
      end

      def raw_material_type_list_only
        @raw_material_type = Rawmaterialtype.all

        render json: @raw_material_type, status: :ok
      end

      private

      def set_raw_material_type
        @raw_material_type = Rawmaterialtype.find(params[:id])
      end

      def raw_material_type_params
        params.permit(:name)
      end
    end
  end
end
