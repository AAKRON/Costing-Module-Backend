# frozen_string_literal: true
module Api
  module V1
    class SessionsController < BaseController
      def create
        user = User.find_by_username(params[:username]).try(:authenticate, params[:password])
        if user
          payload = {
            sub: user.id,
            username: user.username,
            role: user.role
          }
          jwt_token = JwtService.encode(payload, 60.minutes.from_now)
          render json: { token: jwt_token }
        else
          render json: { message: 'invalid username or password' }, status: 401
        end
      end
     end
   end
end
