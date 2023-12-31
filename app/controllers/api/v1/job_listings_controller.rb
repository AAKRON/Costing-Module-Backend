# frozen_string_literal: true

module Api
  module V1
    class JobListingsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only: %i[destroy update]
      before_action :set_job, only: %i[job_cost_calculate update show]
      after_action(only: [:index]) { set_pagination_header(JobWithScreenListing.count) }
      after_action(only: [:job_list_only]) { set_pagination_header(JobListing.count) }

      def index
        screen_id = (params.fetch(:screen_id, '') == 'null' ) ? '' : params.fetch(:screen_id, '')
        job_number = (params.fetch(:job_number, '') == 'null' ) ? '' : params.fetch(:job_number, '')

        # set_pagination_header(JobWithScreenListing.count)
        _start = params[:_start].to_i
        _end = params[:_end].to_i
        # @job_listings = JobWithScreenListing.paginate(params.slice(:_end, :_sort, :_order))
        @job_listings = JobWithScreenListing.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @job_listings = @job_listings.search(job_number, :job_number) unless job_number.empty?
        @job_listings = @job_listings.where("screen_id = #{screen_id}") unless screen_id.empty?
        @job_listings = @job_listings.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @job_listings = @job_listings.search(params[:wages_hr], :wages_per_hour) unless params.fetch(:wages_hr, '').empty?
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

      def show
        render json: @job, status: :ok
      end

      def jobs_by_params
        query_params = params.permit(:description, :wages_per_hour, :screen_size, :job_number)
        # @job_listings = JobWithScreenListing.paginate(params.slice(:_end, :_sort, :_order))

        query = JobWithScreenListing.all

        if query_params[:description].present?
          query = query.where('description ILIKE ?', "%#{query_params[:description]}%")
        end

        if query_params[:screen_size].present?
          query = query.where('screen_size ILIKE ?', "%#{query_params[:screen_size]}%")
        end

        if query_params[:wages_per_hour].present?
          query = query.where('CAST(wages_per_hour AS TEXT) ILIKE ?', "%#{query_params[:wages_per_hour]}%")
        end

        if query_params[:job_number].present?
          query = query.where('job_number ILIKE ?', "%#{query_params[:job_number]}%")
        end

        @jobs = query.all
        render json: @jobs, status: :ok
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
        # set_pagination_header(JobListing.count)
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
