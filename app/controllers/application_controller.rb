# frozen_string_literal: true
class ApplicationController < ActionController::API
  # protect_from_forgery with: :null_session
  
  # Define restrict_access method that can be optionally used by subcontrollers
  private
  
  def restrict_access
    # Default implementation - override in subcontrollers that need authentication
    true
  end
end
