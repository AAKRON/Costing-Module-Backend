# frozen_string_literal: true
module Api
  module V1
    class FinalCalculationsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only: [:destroy, :update]
      after_action(only: [:index]) { set_pagination_header(BlankFinalCalculationsView.count) }

      def index
        _start = params[:_start].to_i
        _end   = params[:_end].to_i
        @final_calculations = BlankFinalCalculationsView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @final_calculations = @final_calculations.search(params[:q], :blank_number) unless params.fetch(:q, '').empty?
        @final_calculations = @final_calculations.where('color_description ILIKE ?', "%#{params[:color_description]}%") unless params.fetch(:color_description, '').empty?
        @final_calculations = @final_calculations.where('blank_name ILIKE ?', "%#{params[:blank_name]}%") unless params.fetch(:blank_name, '').empty?
        @final_calculations = @final_calculations.where('raw_material ILIKE ?', "%#{params[:raw_material]}%") unless params.fetch(:raw_material, '').empty?

        render json: @final_calculations.map { |fc|
          {
            id: fc.id,
            blank_number: fc.blank_number,
            blank_name: fc.blank_name,
            color_description: fc.color_description,
            raw_material: fc.raw_material,
            raw_calculated: fc.raw_calculated || ' nil',
            cost_of_colorant_or_lacquer: fc.cost_of_colorant_or_lacquer || ' nil',
            total: fc.total || ' nil',
            ave_cost: fc.ave_cost || ' nil'
          }
        }, status: :ok
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

        color_one_cost = 0.0
        color_two_cost = 0.0
        raw_calculated = (@final_calculation.raw_material.cost / @final_calculation.number_of_pieces_per_unit_one).round(5)

        color_one_cost = Color.where(name: @final_calculation.colorant_one).first&.cost_of_color || 0.0 if @final_calculation.colorant_one.present?
        color_two_cost = Color.where(name: @final_calculation.colorant_two).first&.cost_of_color || 0.0 if @final_calculation.colorant_two.present?

        final_color_one_cost = ((color_one_cost * @final_calculation.percentage_of_colorant_one) / @final_calculation.number_of_pieces_per_unit_one).round(5)
        final_color_two_cost = ((color_two_cost * @final_calculation.percentage_of_colorant_two) / @final_calculation.number_of_pieces_per_unit_two).round(5)
        cost_of_colorant_or_lacquer = (final_color_one_cost + final_color_two_cost).round(5)

        render json: {
          id: @final_calculation.id,
          blank_id: @final_calculation.blank_id,
          color_number: @final_calculation.color_number,
          color_description: @final_calculation.color_description,
          raw_material_id: @final_calculation.raw_material_id,
          colorant_one: @final_calculation.colorant_one,
          number_of_pieces_per_unit_one: @final_calculation.number_of_pieces_per_unit_one,
          percentage_of_colorant_one: @final_calculation.percentage_of_colorant_one,
          colorant_two: @final_calculation.colorant_two,
          number_of_pieces_per_unit_two: @final_calculation.number_of_pieces_per_unit_two,
          percentage_of_colorant_two: @final_calculation.percentage_of_colorant_two,
          raw_material_name: @final_calculation.raw_material.name,
          raw_material_cost: @final_calculation.raw_material.cost,
          raw_calculated: raw_calculated,
          color_one_cost: color_one_cost,
          color_two_cost: color_two_cost,
          fina_color_one_cost: final_color_one_cost,
          fina_color_two_cost: final_color_two_cost,
          cost_of_colorant_or_lacquer: cost_of_colorant_or_lacquer,
          total_cost: (raw_calculated + cost_of_colorant_or_lacquer).round(5),
          blank_final_calculations_view: BlankFinalCalculationsView.where(blank_number: @final_calculation.blank_id).as_json,
          blank_average_cost: BlankAverageCost.find_by_blank_id(@final_calculation.blank_id)&.average_cost_of_blank || 0.0
        }, status: :ok
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
          :number_of_pieces_per_unit_two, :percentage_of_colorant_two
        )
      end
    end
  end
end
