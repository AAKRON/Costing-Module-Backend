# frozen_string_literal: true
module Api
  module V1
    class ItemJobsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_item_job, only: [:update]
      after_action(only: [:index]) { set_pagination_header(ItemWithJobCount.count) }

      def index
        #set_pagination_header(ItemWithJobCount.count)
        item_number = (params.fetch(:item_number, '') == 'null' ) ? '' : params.fetch(:item_number, '')
        number_of_jobs = (params.fetch(:number_of_jobs, '') == 'null' ) ? '' : params.fetch(:number_of_jobs, '')

        _start = params[:_start].to_i
        _end = params[:_end].to_i
        
        # @items = ItemWithJobCount.paginate(params.slice(:_end, :_sort, :_order))
        @items = ItemWithJobCount.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @items = @items.search(params[:item_number], :item_number) unless params.fetch(:item_number, '').empty?
        @items = @items.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @items = @items.where("number_of_jobs = #{number_of_jobs}") unless number_of_jobs.empty?

        render_item_and_item_jobs_template(template_name: :list, status: :ok)
      end

      def create
        @item = Item.find_by_item_number!(item_job_params[:item_number])
        @item.item_jobs.build(item_job_params[:item_jobs]) if item_job_params[:item_jobs]

        render_item_and_item_jobs_template(template_name: :show, status: :created) if @item.save
        render json: @item.errors, status: :bad_request unless @item.save
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
        if @itemJob.update(job_listing_id: params[:job_listing_id],hour_per_piece:params[:hour_per_piece])
            render json: @itemJob, status: :ok
        else
            render json: @itemJob.errors.messages, status: :bad_request
        end
      end

      def destroy
        params[:jobs].map do |row|
            if row[:deleted]
              ItemJob.where(item_id: params[:id], job_listing_id: row[:job_listing_id]).destroy_all
            end
        end if params.has_key?(:jobs)
        @itemJobs = ItemJob.where(item_id: params[:id])
        render json: @itemJobs, status: :ok
      end

      def show
        @item = Item.find_by_id!(params[:id])
        render_item_and_item_jobs_template(template_name: __method__, status: :ok)
      end

      private

      def item_job_params
        params.permit(:item_number, item_jobs: [:job_listing_id, :hour_per_piece])
      end

      def set_item_job
        @itemJob = ItemJob.find(params[:id])
      end

      def render_item_and_item_jobs_template(template_name: :index, status: :ok)
        render template: "api/v1/item_jobs/#{template_name.to_s}.json", status: status
      end

      def item_job_body(jobs, item_number)
        jobs.map! do |row|
          job_number = row[:job_listing_id].to_i
          Hash[:hour_per_piece, row[:hour_per_piece].to_f, :item_id, params[:item_number],
                 :job_listing_id, job_number, :cell_key, job_number.to_s + item_number.to_s
          ]
        end
      end
    end
  end
end
