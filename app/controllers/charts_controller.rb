# frozen_string_literal: true
module Api
  module V1
    class ChartsController < BaseController
      before_action :restrict_access
      before_action :set_jobs_charts, only: [:get_charts_info]
      before_action :set_blanks_charts, only: [:get_charts_info]

      def get_charts_info
        result_data = {
            number_of_jobs_created_each_day: {
                dates: @jobs_dates,
                data: @jobs_counts
            },
            # number_of_jobs_created_each_month: {
            #     dates: @jobs_months,
            #     data: @jobs_months_counts
            # },
            number_of_blanks_created_each_day: {
                dates: @blanks_dates,
                data: @blanks_counts
            },
            # number_of_blanks_by_type: {
            #     categories: @blanks_types,
            #     data: @blanks_type_counts
            # },
        }
        render json: result_data, status: :ok
      end

      private

      def set_jobs_charts
        jobs_by_date = JobListing.where("created_at > ?", "%#{params[:start_date]}%")
        .where("created_at < ?", "%#{params[:end_date]}%")
        .order('DATE(created_at) ASC')
        .group("DATE(created_at)").count
        @jobs_dates = jobs_by_date.keys
        @jobs_counts = jobs_by_date.values

        # jobs_by_month = JobListing.order('MONTH(created_at) ASC').group("MONTH(created_at)").count
        # @jobs_months = jobs_by_date.keys
        # @jobs_months_counts = jobs_by_date.values
      end

      def set_blanks_charts
        blanks_by_date = Blank.where("created_at > ?", "%#{params[:start_date]}%")
        .where("created_at < ?", "%#{params[:end_date]}%")
        .order('DATE(created_at) ASC')
        .group("DATE(created_at)").count

        @blanks_dates = blanks_by_date.keys
        @blanks_counts = blanks_by_date.values

        # blanks_by_type = Blank.joins(:blank_type)
        #                     .group('blank_types.name')
        #                     .select('blank_types.name')
        #                     .count
        # @blanks_types = blanks_by_type.name
        # @blanks_type_counts = blanks_by_type.count
      end
    end
  end
end
