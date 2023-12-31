# frozen_string_literal: true
module Api
  module V1
    class ScreensController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_screen, only: [:show, :update]
      after_action(only: [:index]) { set_pagination_header(Screen.count) }

      def index
        screen_id = (params.fetch(:id, '') == 'null' ) ? '' : params.fetch(:id, '')
        screen_id_select = (params.fetch(:screen_id, '') == 'null' ) ? '' : params.fetch(:screen_id, '')

        #set_pagination_header(Screen.count)
        @screens = Screen.paginate(params.slice(:_end, :_sort, :_order))
        @screens = @screens.search(screen_id, :id) unless screen_id.empty?
        @screens = @screens.where("id = #{screen_id_select}") unless screen_id_select.empty?
        @screens = @screens.search(params[:cost], :cost) unless params.fetch(:cost, '').empty?

        render template: 'api/v1/screens/index.json', status: 200
      end

      def create
        @screen = Screen.new(screen_params)

        if @screen.save
          render json: @screen, status: 201
        else
          render json: @screen.errors, status: 400
        end
      end

      def update
        if @screen.update(screen_params)
          render template: 'api/v1/screens/show.json', status: 201
        else
          render json: @screen.errors, status: 400
        end
      end

      def destroy
        @screen = Screen.find(params[:id])
        @screen.destroy

        render json: "deleted successfully", status: :no_content
      end

      def show
        render json: @screen, status: :ok
      end

      private

      def screen_params
        params.require(:screen).permit(:id, :screen_size, :cost)
      end

      def set_screen
        @screen = Screen.find(params[:id])
      end
    end
  end
end
