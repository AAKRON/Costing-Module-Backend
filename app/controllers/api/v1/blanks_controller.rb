# frozen_string_literal: true
module Api
  module V1
    class BlanksController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blank, only: [:show, :update]
      after_action only: [:index] { set_pagination_header(BlankCostView.count) }
      after_action only: [:blank_list_only] { set_pagination_header(Blank.count) }

      def index
        @blanks = BlankCostView.paginate(params.slice(:_end, :_sort, :_order))
        @blanks = @blanks.search(params[:q], :blank_number) unless params.fetch(:q, '').empty?

        render_blanks_template(template_name: :list, status: :ok)
      end

      def show
        render_blanks_template(template_name: __method__, status: :ok)
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

        if (params.key?("type_id") && params[:type_id] !='')
          @blanks = Blank.where("blank_type_id = 1").order(:blank_number)
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
        @blank.update_attribute(:blank_type_id,  @blank_type.type_number)
      end

      def render_blanks_template(template_name: :index, status: :ok)
        render template: "api/v1/blanks/#{template_name.to_s}.json", status: status
      end
    end
  end
end
