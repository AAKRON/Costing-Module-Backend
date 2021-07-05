# frozen_string_literal: true
module Api
  module V1
    class FinalCalculationsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      after_action (only: [:index]) { set_pagination_header(BlankFinalCalculationsView.count) }

      def index
        @final_calculations = BlankFinalCalculationsView.paginate(params.slice(:_end, :_sort, :_order))
        @final_calculations = @final_calculations.search(params[:q], :blank_number) unless params.fetch(:q, '').empty?
        render_final_calculation_template(template_name: :list, status: :ok)
      end

      def create
        @final_calc = FinalCalculation.new(final_calculation_params)

        if @final_calc.save
          render json: @final_calc, status: :created
        else
          render json: @final_calc.errors, status: :not_ok
        end
      end

      def update
        @final_calc = FinalCalculation.find(params[:id])

        if @final_calc.update(final_calculation_params)
          render json: @final_calc, status: :ok
        else
          render json: @final_calc.errors, status: :bad_request
        end
      end

      def show
        @final_calculation = FinalCalculation.find(params[:id])

        render_final_calculation_template(template_name: __method__, status: :ok)
      end

      def destroy
        FinalCalculation.find(params[:id]).destroy
      end

      private

      def final_calculation_params
        params.require(:final_calculation).permit(
          :blank_id, :color_number, :color_description,
          :raw_material_id, :colorant_one, :number_of_pieces_per_unit_one,
          :percentage_of_colorant_one, :colorant_two,
          :number_of_pieces_per_unit_two, :percentage_of_colorant_two,
        )
      end

      def render_final_calculation_template(template_name: :index, status: :ok)
        render template: "api/v1/final_calculations/#{template_name.to_s}.json", status: status
      end
    end
  end
end
