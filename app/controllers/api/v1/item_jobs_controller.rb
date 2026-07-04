# frozen_string_literal: true
module Api
  module V1
    class ItemJobsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only: [:destroy, :update]
      before_action :set_item_job, only: [:update]
      after_action(only: [:index]) { set_pagination_header(ItemWithJobCount.count) }

      def index
        item_number  = (params.fetch(:item_number, '')  == 'null') ? '' : params.fetch(:item_number, '')
        number_of_jobs = (params.fetch(:number_of_jobs, '') == 'null') ? '' : params.fetch(:number_of_jobs, '')

        _start = params[:_start].to_i
        _end   = params[:_end].to_i
        @items = ItemWithJobCount.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @items = @items.search(params[:item_number], :item_number) unless params.fetch(:item_number, '').empty?
        @items = @items.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @items = @items.where("number_of_jobs = #{number_of_jobs}") unless number_of_jobs.empty?

        render json: @items.map { |item|
          {
            id: item.id,
            item_number: item.item_number,
            description: item.description,
            number_of_jobs: item.number_of_jobs
          }
        }, status: :ok
      end

      def create
        @item = Item.find_by_item_number!(item_job_params[:item_number])
        @item.item_jobs.build(item_job_params[:item_jobs]) if item_job_params[:item_jobs]

        if @item.save
          render json: build_item_jobs_json(@item), status: :created
        else
          render json: @item.errors, status: :bad_request
        end
      end

      def update_item_jobs_only
        ItemJob.bulk_update_or_create(
          item_job_body(params[:copy_jobs], params[:item_number]),
          :cell_key,
          key_as_id: false
        )
        @itemJobs = ItemJob.where(item_id: params[:item_number])
        render json: @itemJobs, status: :ok
      end

      def update
        if @itemJob.update(job_listing_id: params[:job_listing_id], hour_per_piece: params[:hour_per_piece])
          render json: @itemJob, status: :ok
        else
          render json: @itemJob.errors.messages, status: :bad_request
        end
      end

      def destroy
        if params.has_key?(:jobs)
          params[:jobs].map do |row|
            ItemJob.where(item_id: params[:id], job_listing_id: row[:job_listing_id]).destroy_all if row[:deleted]
          end
        end
        @itemJobs = ItemJob.where(item_id: params[:id])
        render json: @itemJobs, status: :ok
      end

      def show
        @item = Item.find_by_id!(params[:id])
        render json: build_item_jobs_json(@item), status: :ok
      end

      private

      def build_item_jobs_json(item)
        jobs_data = item.item_jobs.map do |job|
          job = ItemJobDecorator.new(job)
          {
            job_pk_id: job.id,
            job_number: job.job_number,
            description: job.description,
            wages_per_hour: job.wages_per_hour,
            hour_per_piece: job.hour_per_piece.round(5),
            direct_labor_cost: job.direct_labor_cost,
            overhead_inventory_cost: job.overhead_inventory_cost,
            overhead_pricing_cost: job.overhead_pricing_cost,
            job_listing_id: job.job_listing_id
          }
        end
        {
          id: item.id,
          item_number: item.item_number,
          description: item.description,
          number_of_jobs: item.item_jobs.count,
          jobs: jobs_data
        }
      end

      def item_job_params
        params.permit(:item_number, item_jobs: [:job_listing_id, :hour_per_piece])
      end

      def set_item_job
        @itemJob = ItemJob.find(params[:id])
      end

      def item_job_body(jobs, item_number)
        jobs.map! do |row|
          job_number = row[:job_listing_id].to_i
          Hash[:hour_per_piece, row[:hour_per_piece].to_f, :item_id, params[:item_number],
               :job_listing_id, job_number, :cell_key, job_number.to_s + item_number.to_s]
        end
      end
    end
  end
end
