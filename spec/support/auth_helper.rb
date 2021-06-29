module Requests
  module AuthHelper
    def user
      user ||= create(:user)
    end

    def get_with_token(path, params={}, headers={})
      headers.merge!('HTTP_AUTHORIZATION': "Bearer #{user.token}")
      get(path, params: params, headers:  headers)
    end

    def post_with_token(path, params={}, headers={})
      headers.merge!('HTTP_AUTHORIZATION': "Bearer #{user.token}")
      post(path, params: params, headers:  headers)
    end

    def put_with_token(path, params={}, headers={})
      headers.merge!('HTTP_AUTHORIZATION': "Bearer #{user.token}")
      put(path, params: params, headers:  headers)
    end

    def delete_with_token(path, params={}, headers={})
      headers.merge!('HTTP_AUTHORIZATION': "Bearer #{user.token}")
      delete(path, params: params, headers:  headers)
    end
  end
end
