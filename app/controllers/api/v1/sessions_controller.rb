# frozen_string_literal: true
module Api
  module V1
    class SessionsController < BaseController
      def create
        user = User.find_by_username(params[:username]).try(:authenticate, params[:password])
        if user
          render json: { username: user.username, token: user.token, role: user.role }
        else
          render json: { message: 'invalid username or password' }, status: 401
        end
      end
     end
   end
end
