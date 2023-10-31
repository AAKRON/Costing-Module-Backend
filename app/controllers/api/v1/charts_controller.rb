# frozen_string_literal: true
module Api
  module V1
    class ChartsController < BaseController
      before_action :restrict_access
      before_action :set_jobs_charts, only: [:get_charts_info]
      before_action :set_blanks_charts, only: [:get_charts_info]
      before_action :set_items_charts, only: [:get_charts_info]

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
            number_of_blanks_by_type: {
                categories: @blanks_types,
                data: @blanks_type_counts
            },
            number_of_items_created_each_day: {
                dates: @items_dates,
                data: @items_counts
            },
            number_of_items_by_type: {
                categories: @items_types,
                data: @items_type_counts
            },
        }
        render json: result_data, status: :ok
      end

      private

      def set_jobs_charts
        # Get jobs with the filters applied
        jobs_with_filters = JobListing.where("job_listings.created_at >= ?", "%#{params[:start_date]}%")
                                        .where("job_listings.created_at <= ?", "%#{params[:end_date]}%")

        # Get jobs by date
        jobs_by_date = jobs_with_filters
                        .order('DATE(created_at) ASC')
                        .group("DATE(created_at)").count

        @jobs_dates = jobs_by_date.keys
        @jobs_counts = jobs_by_date.values

        # # Get jobs by month
        # jobs_by_month = jobs_with_filters
        # .group('extract(month from created_at)').count

        # @jobs_months = jobs_by_date.keys
        # @jobs_months_counts = jobs_by_date.values
      end

      def set_blanks_charts
        # Get blanks with the filters applied
        blanks_with_filters = Blank.where("blanks.created_at >= ?", "%#{params[:start_date]}%")
                                .where("blanks.created_at <= ?", "%#{params[:end_date]}%")

        # Get blanks by date
        blanks_by_date = blanks_with_filters
                            .order('DATE(created_at) ASC')
                            .group("DATE(created_at)").count

        @blanks_dates = blanks_by_date.keys
        @blanks_counts = blanks_by_date.values

        # Get blanks per type
        blanks_by_type = Blank
                            .left_outer_joins(:blank_type)
                            .group('blank_types.description')
                            .count

        @blanks_types = blanks_by_type.keys
        @blanks_type_counts = blanks_by_type.values
      end

      def set_items_charts
        # Get items with the filters applied
        items_with_filters = Item.where("items.created_at >= ?", "%#{params[:start_date]}%")
                                .where("items.created_at <= ?", "%#{params[:end_date]}%")

        # Get items by date
        items_by_date = items_with_filters
                            .order('DATE(created_at) ASC')
                            .group("DATE(created_at)").count

        @items_dates = items_by_date.keys
        @items_counts = items_by_date.values

        # Get items per type
        items_by_type = Item
                            .left_outer_joins(:item_type)
                            .group('item_types.description')
                            .count

        @items_types = items_by_type.keys
        @items_type_counts = items_by_type.values
      end
    end
  end
end
