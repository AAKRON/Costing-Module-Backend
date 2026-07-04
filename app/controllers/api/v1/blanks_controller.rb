# frozen_string_literal: true
module Api
  module V1
    class BlanksController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only: [:destroy, :update]
      before_action :set_blank, only: [:show, :update]
      after_action(only: [:index]) { set_pagination_header(BlankCostView.count) }
      after_action(only: [:blank_list_only]) { set_pagination_header(Blank.count) }

      def index
        blank_number = (params.fetch(:blank_number, '') == 'null') ? '' : params.fetch(:blank_number, '')
        blank_type_id = (params.fetch(:blank_type_id, '') == 'null') ? '' : params.fetch(:blank_type_id, '')
        cost = (params.fetch(:cost, '') == 'null') ? '' : params.fetch(:cost, '')
        total_blank_cost_for_price = (params.fetch(:total_blank_cost_for_price, '') == 'null') ? '' : params.fetch(:total_blank_cost_for_price, '')
        total_blank_cost_for_inventory = (params.fetch(:total_blank_cost_for_inventory, '') == 'null') ? '' : params.fetch(:total_blank_cost_for_inventory, '')

        _start = params[:_start].to_i
        _end = params[:_end].to_i
        @blanks = BlankCostView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @blanks = @blanks.search(blank_number, :blank_number) unless blank_number.empty?
        @blanks = @blanks.where("blank_type_id = #{blank_type_id}") unless blank_type_id.empty?
        @blanks = @blanks.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @blanks = @blanks.search(cost, :cost) unless cost.empty?
        @blanks = @blanks.search(total_blank_cost_for_price, :total_blank_cost_for_price) unless total_blank_cost_for_price.empty?
        @blanks = @blanks.search(total_blank_cost_for_inventory, :total_blank_cost_for_inventory) unless total_blank_cost_for_inventory.empty?

        render json: @blanks.map { |blank|
          {
            id: blank.id,
            blank_number: blank.blank_number,
            description: blank.description,
            blank_type: blank.blank_type,
            cost: blank.cost.round(5),
            blank_type_id: blank.blank_type_id,
            type_number: blank.type_number,
            total_blank_cost_for_price: blank.total_blank_cost_for_price.round(5),
            total_blank_cost_for_inventory: blank.total_blank_cost_for_inventory.round(5)
          }
        }, status: :ok
      end

      def show
        job_price_cost = 0.0
        job_inventory_cost = 0.0
        blank_average_cost = 0.0

        jobs_data = @blank.blank_jobs.map do |job|
          job = BlankJobDecorator.new(job)
          job_price_cost += job.total_pricing_cost.to_f
          job_inventory_cost += job.total_inventory_cost.to_f
          {
            job_number: job.job_number,
            description: job.description,
            wages_per_hour: job.wages_per_hour,
            hour_per_piece: job.hour_per_piece.round(5),
            direct_labor_cost: job.direct_labor_cost,
            overhead_inventory_cost: job.overhead_inventory_cost,
            overhead_pricing_cost: job.overhead_pricing_cost,
            job_listing_id: job.job_listing_id,
            total_inventory_cost: job.total_inventory_cost.round(5),
            total_pricing_cost: job.total_pricing_cost.round(5)
          }
        end

        avg = BlankAverageCost.find_by_blank_id(@blank.blank_number)
        blank_average_cost = avg.average_cost_of_blank unless avg.nil?

        render json: {
          id: @blank.id,
          blank_number: @blank.blank_number,
          description: @blank.description,
          blank_type: @blank.blank_type.description,
          cost: @blank.cost.round(5),
          blank_type_id: @blank.blank_type.id,
          type_number: @blank.blank_type.type_number,
          jobs: jobs_data,
          job_price_cost: job_price_cost.round(5),
          job_inventory_cost: job_inventory_cost.round(5),
          blank_average_cost: blank_average_cost.round(5),
          total_price_cost: (job_price_cost.round(5) + blank_average_cost.round(5)).round(5),
          total_inventory_cost: (job_inventory_cost.round(5) + blank_average_cost.round(5)).round(5)
        }, status: :ok
      end

      def create
        @blank = Blank.new(blank_params)

        if @blank.save
          update_blank_type(params[:blank_type_id])
          render json: @blank, status: 201
        else
          render json: @blank.errors, status: 400
        end
      end

      def update
        if @blank.update(blank_params)
          update_blank_type(params[:blank_type_id])
          render json: @blank, status: :ok
        else
          render json: @blank.errors.messages, status: :bad_request
        end
      end

      def destroy
        Blank.find_by_id!(params[:id]).destroy
      end

      def blank_list_only
        if params.key?('type_id') && params[:type_id] != ''
          @blanks = Blank.where('blank_type_id = 1').order(:blank_number)
        else
          @blanks = Blank.all.order(:blank_number)
        end
        render json: @blanks, status: :ok
      end

      private

      def blank_params
        params.require(:blank).permit(:id, :blank_number, :description, :cost, :blank_type_id)
      end

      def set_blank
        @blank = Blank.find(params[:id])
      end

      def update_blank_type(blank_type_id)
        @blank_type = BlankType.find_by_id(blank_type_id)
        @blank.update_attribute(:blank_type_id, @blank_type.type_number)
      end
    end
  end
end
