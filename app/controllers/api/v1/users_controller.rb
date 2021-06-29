# frozen_string_literal: true
module Api
  module V1
    class UsersController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level
      before_action :set_user, only: :update
      #after_action only: [:index] { set_pagination_header(User.count) }
      after_action :set_pagination_header(User.count), only: [:index]

      def index
        @users = User.paginate(params.slice(:_end, :_sort, :_order))
        @users = @users.search(params[:q], :username) unless params.fetch(:q, '').empty?
        render json: @users, status: 200
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: 201
        else
          render json: @user.errors, status: 400
        end
      end

      def show
        @user = User.find(params[:id])

        render json: @user, status: 201
      end

      def update
        if @user.update(user_params)
          render json: @user, status: 201
        else
          render json: @user.errors, status: 400
        end
      end

      def destroy
        @user = User.find(params[:id])
        @user.destroy

        render json: "deleted successfully", status: :no_content
      end

      private

      def user_params
        params.permit(:id, :username, :password, :role)
      end

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
