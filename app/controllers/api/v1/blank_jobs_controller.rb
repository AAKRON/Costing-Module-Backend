# frozen_string_literal: true
module Api
  module V1
    class BlankJobsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      after_action(only: [:index]) { set_pagination_header(BlankJobView.count) }

      def index
        @blank_jobs = BlankJobView.paginate(params.slice(:_end, :_sort, :_order))
        @blank_jobs = @blank_jobs.where("blank_number = #{params[:blank_number]}") unless params.fetch(:blank_number, '').empty?
        @blank_jobs = @blank_jobs.where("lower(description) LIKE ?", "%#{params[:description]}%") unless params.fetch(:description, '').empty?
        @blank_jobs = @blank_jobs.where("number_of_jobs = #{params[:number_of_jobs]}") unless params.fetch(:number_of_jobs, '').empty?

        render_item_and_item_jobs_template(template_name: :list, status: :ok)
      end

      def create
        @blank = Blank.find_by_blank_number!(blank_job_params[:blank_number])
        @blank.blank_jobs.build(blank_job_params[:blank_jobs]) if blank_job_params[:blank_jobs]

        render_item_and_item_jobs_template(template_name: :show, status: :created) if @blank.save
        render json: @blank.errors, status: :bad_request unless @blank.save
      end
	  
	  def update_blank_jobs_data
        @blank = Blank.where(blank_number: params[:blank_number])
        #puts "#{@blank.count}"
        #abort
        if @blank.present?
			@blankJob = BlankJob.find(params[:blank_job_id])
			if @blankJob
				#puts "#{@blankJob.to_json}"
				#puts "Hiii"
				@blankJob.update(job_listing_id: params[:job_listing_id],hour_per_piece:params[:hour_per_piece])
				@blankJobs = BlankJob.where(blank_id: params[:blank_number])
				render json: @blankJobs, status: :ok
				#puts itemJobs.errors.full_messages
			else
				render json: @blankJob.errors.messages, status: :bad_request
			end
		else
			render(json: { message: "item not found",status: :bad_request })
		end
      end
      
      def update_blank_jobs_only
        BlankJob.bulk_update_or_create(
          blank_job_body(params[:copy_jobs], params[:blank_number]),
          :cell_key,
          key_as_id: false
        )
        @blankJobs = BlankJob.where(blank_id: params[:blank_number])

        render json: @blankJobs, status: :ok
      end

      def update
        params[:jobs].map do |row|
          if row[:deleted]
            BlankJob.where(blank_id: params[:id], job_listing_id: row[:job_listing_id]).destroy_all
          end
        end if params.has_key?(:jobs)
        @blankJobs = BlankJob.where(blank_id: params[:id])

        render json: @blankJobs, status: :ok
      end

      def show
        @blank = Blank.find_by_id!(params[:id])

        render_item_and_item_jobs_template(template_name: __method__, status: :ok)
      end

      private

      def blank_job_params
        params.permit(:blank_number, blank_jobs: [:job_listing_id, :hour_per_piece])
      end

      def render_item_and_item_jobs_template(template_name: :index, status: :ok)
        render template: "api/v1/blank_jobs/#{template_name.to_s}.json", status: status
      end

      def blank_job_body(jobs, blank_number)
        jobs.map! do |row|
          job_number = row[:job_listing_id].to_i
          Hash[:hour_per_piece, row[:hour_per_piece].to_f, :blank_id, params[:blank_number],
                 :job_listing_id, job_number, :cell_key, job_number.to_s + blank_number.to_s
          ]
        end
      end
    end
  end
end
