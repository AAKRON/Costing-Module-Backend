# frozen_string_literal: true
module Api
  module V1
    class ChartsController < BaseController
      before_action :restrict_access
      before_action :set_jobs_count, only: [:get_charts_info]

      def get_charts_info
        result_data = {
            number_of_jobs_created_each_day: {
                dates: @jobs_dates,
                data: @jobs_counts
            }
        }
        render json: result_data, status: :ok
      end

      private

      def set_jobs_count
        jobs_by_date = JobListing.order('DATE(created_at) DESC').group("DATE(created_at)").count

        @jobs_dates = jobs_by_date.keys
        @jobs_counts = jobs_by_date.values
      end

    end
  end
end
