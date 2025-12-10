# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: Rails.application.config.version || '1.0.0'
    }
  end
end