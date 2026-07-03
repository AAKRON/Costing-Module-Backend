# frozen_string_literal: true
class ApplicationController < ActionController::API
  # protect_from_forgery with: :null_session

  private

  def restrict_access
    true
  end

  def require_admin_key
    provided = request.headers['X-Admin-Key'].presence || params[:admin_key].presence
    expected = ENV['ADMIN_KEY'].presence
    unless expected && provided && ActiveSupport::SecurityUtils.secure_compare(provided, expected)
      render json: { error: 'Unauthorized' }, status: 401
    end
  end
end
