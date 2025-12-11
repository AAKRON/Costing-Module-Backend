# frozen_string_literal: true
class HealthController < ApplicationController
  def show
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      version: '1.0.0',
      rails_version: Rails.version
    }
  end
end