# frozen_string_literal: true
module Api
  module V1
    class BlankRawMaterialsController < BaseController
      before_action :restrict_access, only: [:create, :destroy]
      before_action :set_user_access_level, only: [:destroy, :update]
    end
  end
end
