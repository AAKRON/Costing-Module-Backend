module Api
  module V1
    class VendorsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_vendor, only: [:show, :update, :destroy]
      #after_action only: [:index, :vendor_list_only] { set_pagination_header(Vendor.count) }

      def index
        @vendors = Vendor.all.paginate(params.slice(:_end, :_sort, :_order))
        @vendors = @vendors.search(params[:q], :code) unless params.fetch(:q, '').empty?
        render json: @vendors, status: :ok
      end

      def show
        render json: @vendor, status: :ok
      end

      def create
        @vendor = Vendor.new(vendor_params)

        if @vendor.save
          render json: @vendor, status: :created
        else
          render json: @vendor.errors, status: :unprocessable_entity
        end
      end

      def update
        if @vendor.update(vendor_params)
          render json: @vendor, status: :ok
        else
          render json: @vendor.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @vendor.destroy
      end

      def vendor_list_only
        @vendor = Vendor.all

        render json: @vendor, status: :ok
      end

      private

      def set_vendor
        @vendor = Vendor.find(params[:id])
      end

      def vendor_params
        params.require(:vendor).permit(:name, :code)
      end
    end
  end
end
