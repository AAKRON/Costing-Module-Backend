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
          @inks = Ink.paginate(params.slice(:_end, :_sort, :_order))
          @inks = @inks.search(id, :id) unless id.empty?
          @inks = @inks.search(params[:name], :name) unless params.fetch(:name, '').empty?
          @inks = @inks.search(ink_cost, :ink_cost) unless ink_cost.empty?

          render template: 'api/v1/ink/index.json', status: :ok
        end

        def create
          @ink = Ink.new(ink_params)
          if @ink.save
            render template: 'api/v1/ink/show.json', status: 201
          else
            render json: @ink.errors, status: :bad_request
          end
        end

        def update
          @ink = Ink.find(params[:id])
          if @ink.update(ink_params)
            render json: @ink, status: :ok
          else
            render json: @ink.errors, status: :bad_request
          end
        end

        def show
          @ink = Ink.find(params[:id])
          render json: @ink, status: :ok
        end

        def destroy
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
        end

        def ink_params
          params.permit(:name, :ink_cost)
        end
      end
    end
  end
