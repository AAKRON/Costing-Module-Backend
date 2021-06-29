module Api
  module V1
    class UnitsOfMeasuresController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_units_of_measure, only: [:show, :update, :destroy]
      after_action only: [:index, :units_of_measure_list_only] { set_pagination_header(UnitsOfMeasure.count) }

      # GET /units_of_measures
      # GET /units_of_measures.json
      def index
        @units_of_measures = UnitsOfMeasure.all.paginate(params.slice(:_end, :_sort, :_order))
        @units_of_measures = @units_of_measures.search(params[:q], :name) unless params.fetch(:q, '').empty?
        render json: @units_of_measures, status: :ok
      end

      # GET /units_of_measures/1
      # GET /units_of_measures/1.json
      def show
        render json: @units_of_measure, status: :ok
      end

      # POST /units_of_measures
      # POST /units_of_measures.json
      def create
        @units_of_measure = UnitsOfMeasure.new(units_of_measure_params)

        if @units_of_measure.save
          render json: @units_of_measure, status: :created
        else
          render json: @units_of_measure.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /units_of_measures/1
      # PATCH/PUT /units_of_measures/1.json
      def update
        if @units_of_measure.update(units_of_measure_params)
          render json: @units_of_measure, status: :ok
        else
          render json: @units_of_measure.errors, status: :unprocessable_entity
        end
      end

      # DELETE /units_of_measures/1
      # DELETE /units_of_measures/1.json
      def destroy
        @units_of_measure.destroy
      end

      def units_of_measure_list_only
        @units_of_measure = UnitsOfMeasure.all

        render json: @units_of_measure, status: :ok
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_units_of_measure
        @units_of_measure = UnitsOfMeasure.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def units_of_measure_params
        params.require(:units_of_measure).permit(:name, :abbr)
      end
    end
  end
end
