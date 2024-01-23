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

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0
        @job_listings = JobWithScreenListing.filter_by_location(_location_id, _order, _start, _limit, job_number, screen_id, params[:description], params[:wages_hr])
        render template: 'api/v1/job_listings/index.json', status: :ok
      end

      def create
        @job = JobListing.new(job_listing_params)
        if @job.save
          update_or_create_location_prices # location prices
          render json: @job, status: 201
        else
          render json: @job.errors, status: 400
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
        job_listing_params = update_or_create_location_prices # location prices
        if @job.update(job_listing_params)
          set_job # update location prices
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

        # Add location prices if exist
        if @location.present?
            @jobs_location = JobLocationPrice.where(job_listings_id: params[:id]).where(locations_id: @location[:id]).first
            if @jobs_location.present?
                @job[:wages_per_hour] = @jobs_location[:wages_per_hour]
            end
        end
      end

      def update_or_create_location_prices
        logger.debug "update_or_create_location_prices #{6}"

        if @jobs_location.present?
            @jobs_location.update(wages_per_hour: params[:wages_per_hour])
        else
            @jobs_location = JobLocationPrice.new(wages_per_hour: params[:wages_per_hour], locations_id: @location[:id], job_listings_id: @job[:id])
            @jobs_location.save
        end

        # Keep params that are not prices
        if @location.present?
            return params.require(:job_listing).permit(:description, :screen_id, :job_number)
        else
            return job_listing_params
        end
      end

    end
  end
end
