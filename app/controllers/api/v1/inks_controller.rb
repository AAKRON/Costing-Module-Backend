# frozen_string_literal: true
module Api
    module V1
      class InksController < BaseController
        before_action :restrict_access
        before_action :set_user_access_level, only:[:create, :destroy, :update]
        before_action :set_ink, only: [:show, :update, :destroy]
        after_action(only: [:index]) { set_pagination_header(Ink.count) }
        after_action(only: [:ink_list_only]) { set_pagination_header(Ink.count) }

        def index
            id = (params.fetch(:id, '') == 'null' ) ? '' : params.fetch(:id, '')
            ink_cost = (params.fetch(:ink_cost, '') == 'null' ) ? '' : params.fetch(:ink_cost, '')
            name = params.fetch(:name, '')

            _start = params[:_start].to_i
            _limit = params[:_end].to_i - _start
            _order = "#{params[:_sort]} #{params[:_order]}"
            _location_id = @location ? @location.id : 0
            @inks = InksLocationPrice.filter_by_location(_location_id, _order, _start, _limit, id, ink_cost, name)

            render template: 'api/v1/ink/index.json', status: :ok
        end

        def create
          @ink = Ink.new(ink_params)
          if @ink.save
            update_or_create_location_prices # location prices
            render template: 'api/v1/ink/show.json', status: 201
          else
            render json: @ink.errors, status: :bad_request
          end
        end

        def update
          @ink = Ink.find(params[:id])
          ink_params = update_or_create_location_prices # location prices
          if @ink.update(ink_params)
            set_ink # update location prices
            render json: @ink, status: :ok
          else
            render json: @ink.errors, status: :bad_request
          end
        end

        def show
          render json: @ink, status: :ok
        end

        def destroy
          InksLocationPrice.where(inks_id: params[:id]).first.try(:destroy)
          Ink.find(params[:id]).destroy
          head :no_content
        end

        def ink_list_only
          @inks = Ink.all

          render json: @inks, status: :ok
        end

        private

        def set_ink
          @ink = Ink.find(params[:id])

          # Add location prices if exist
          if @location.present?
              @inks_location = InksLocationPrice.where(inks_id: params[:id]).where(locations_id: @location[:id]).first
              if @inks_location.present?
                  @ink[:ink_cost] = @inks_location[:ink_cost]
              end
          end
        end

        def ink_params
          params.permit(:name, :ink_cost)
        end

        def update_or_create_location_prices
            if @location.present?
                if @inks_location.present?
                    @inks_location.update(ink_cost: params[:ink_cost])
                else
                    @inks_location = InksLocationPrice.new(ink_cost: params[:ink_cost], locations_id: @location[:id], inks_id: @ink[:id])
                    @inks_location.save
                end
                # Keep params that are not prices
                return params.permit(:name)
            else
                return ink_params  # Keep all params if there are no location
            end
        end
      end
    end
  end
