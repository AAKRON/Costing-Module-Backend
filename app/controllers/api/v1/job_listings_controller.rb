# frozen_string_literal: true
module Api
  module V1
    class JobListingsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_job, only:[:job_cost_calculate, :update]
      #after_action only: [:index] { set_pagination_header(JobWithScreenListing.count) }
      ##after_action :set_pagination_header(JobWithScreenListing.count), only: [:index]
      #after_action only: [:job_list_only] { set_pagination_header(JobListing.count) }
      ##after_action :set_pagination_header(JobListing.count), only: [:job_list_only]

      def index
        @job_listings = JobWithScreenListing.paginate(params.slice(:_end, :_sort, :_order))
        @job_listings = @job_listings.search(params[:q], :job_number) unless params.fetch(:q, '').empty?
        render template: 'api/v1/job_listings/index.json', status: :ok
      end

      def create
        @job_listing = JobListing.new(job_listing_params)

        if @job_listing.save
          render json: @job_listing, status: 201
        else
          render json: @job_listing.errors, status: 400
        end
      end

      def update
        if @job.update(job_listing_params)
          render json: @job, status: :ok
        else
          render json: @job.errors, status: :bad_request
        end
      end

      def destroy
        JobListing.find_by_id!(params[:id]).destroy
      end

      def job_list_only
        @job_listing = JobListing.all

        render json: @job_listing, status: :ok
      end

      def job_cost_calculate
        @hour_per_piece = params[:hour_per_piece]
        render template: 'api/v1/job_listings/cost_calculate.json', status: :ok
      end

      private

      def job_listing_params
        params.require(:job_listing).permit(:description, :wages_per_hour, :screen_id, :job_number)
      end

      def set_job
        @job = JobListing.find_by_id!(params[:id])
      end
    end
  end
end
