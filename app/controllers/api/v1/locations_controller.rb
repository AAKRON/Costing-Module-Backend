# frozen_string_literal: true
module Api
    module V1
      class LocationsController < BaseController
        before_action :restrict_access
        before_action :set_user_access_level, only:[:create, :destroy, :update]
        before_action :set_location, only: [:show, :update, :destroy]
        after_action(only: [:index]) { set_pagination_header(Location.count) }
        after_action(only: [:location_list_only]) { set_pagination_header(Location.count) }

        def index
          id = (params.fetch(:id, '') == 'null' ) ? '' : params.fetch(:id, '')
          @locations = Location.order('active_flag DESC').paginate(params.slice(:_end, :_sort, :_order))
          @locations = @locations.search(id, :id) unless id.empty?
          @locations = @locations.search(params[:name], :name) unless params.fetch(:name, '').empty?

          render template: 'api/v1/location/index.json', status: :ok
        end

        def create
          @location = Location.new(location_params)
          if @location.save
            render template: 'api/v1/location/show.json', status: 201
          else
            render json: @location.errors, status: :bad_request
          end
        end

        def update
          @location = Location.find(params[:id])
          if @location.update(location_params)
            render json: @location, status: :ok
          else
            render json: @location.errors, status: :bad_request
          end
        end

        def show
          @location = Location.find(params[:id])
          render json: @location, status: :ok
        end

        def destroy
          Location.find(params[:id]).destroy
          head :no_content
        end

        def location_list_only
          @locations = Location.where("active_flag = 1").order('id ASC')

          render json: @locations, status: :ok
        end

        private

        def set_location
          @location = Location.find(params[:id])
        end

        def location_params
          params.permit(:name, :active_flag)
        end
      end
    end
end
