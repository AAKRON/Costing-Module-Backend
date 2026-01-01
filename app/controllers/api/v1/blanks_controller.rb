# frozen_string_literal: true
module Api
  module V1
    class BlanksController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only:[:destroy, :update]
      before_action :set_blank, only: [:show, :update]
      after_action(only: [:index]) { set_pagination_header(BlankCostView.count) }
      after_action(only: [:blank_list_only]) { set_pagination_header(Blank.count) }

      def index
        blank_number = (params.fetch(:blank_number, '') == 'null' ) ? '' : params.fetch(:blank_number, '')
        blank_type_id = (params.fetch(:blank_type_id, '') == 'null' ) ? '' : params.fetch(:blank_type_id, '')
        description = params.fetch(:description, '')
        cost = (params.fetch(:cost, '') == 'null' ) ? '' : params.fetch(:cost, '')
        total_blank_cost_for_price = (params.fetch(:total_blank_cost_for_price, '') == 'null' ) ? '' : params.fetch(:total_blank_cost_for_price, '')
        total_blank_cost_for_inventory = (params.fetch(:total_blank_cost_for_inventory, '') == 'null' ) ? '' : params.fetch(:total_blank_cost_for_inventory, '')

        _start = params[:_start].to_i
        _limit = params[:_end].to_i - _start
        _order = "#{params[:_sort]} #{params[:_order]}"
        _location_id = @location ? @location.id : 0

        if @database_location_exists
            @blanks = BlankCostView.filter_by_location(_location_id, _order, _start, _limit, blank_number, blank_type_id, description, cost, total_blank_cost_for_price, total_blank_cost_for_inventory)
        else
            @blanks = BlankCostView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_limit)
            @blanks = @blanks.search(blank_number, :blank_number) unless blank_number.empty?
            @blanks = @blanks.where("blank_type_id = #{blank_type_id}") unless blank_type_id.empty?
            @blanks = @blanks.search(params[:description], :description) unless params.fetch(:description, '').empty?
            @blanks = @blanks.search(cost, :cost) unless cost.empty?
            @blanks = @blanks.search(total_blank_cost_for_price, :total_blank_cost_for_price) unless total_blank_cost_for_price.empty?
            @blanks = @blanks.search(total_blank_cost_for_inventory, :total_blank_cost_for_inventory) unless total_blank_cost_for_inventory.empty?
        end

        render_blanks_template(template_name: :list, status: :ok)
      end

      def show
        # add location id to jobs array
        @blank.blank_jobs.map do |blank_job|
            blank_job.location_id = @location ? @location.id : 0
        end
        render_blanks_template(template_name: __method__, status: :ok)
      end

      def create
        @blank = Blank.new(blank_params)
        if @blank.save
          update_blank_type(params[:blank_type_id])
          update_or_create_location_prices # location prices
          render json: @blank, status: 201
        else
          render json: @blank.errors, status: 400
        end
      end

      def update
        @blank = Blank.find(params[:id])
        _blank_params = update_or_create_location_prices # location prices
        _blank_params[:cost] = BigDecimal(params[:cost].to_s) if params[:cost].present?
        if @blank.update(_blank_params)
          update_blank_type(params[:blank_type_id])
          set_blank # update location prices
          render json: @blank, status: :ok
        else
          render json: @blank.errors.messages, status: :bad_request
        end
      end

      def destroy
        BlanksLocationPrice.where(blanks_id: params[:id]).first.try(:destroy)
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
        #params.require(:blank).permit(:id, :blank_number, :description, :cost, :blank_type_id)
        p = params.require(:blank).permit(:id, :blank_number, :description, :cost, :blank_type_id)
        p[:cost] = BigDecimal(p[:cost].to_s) if p[:cost].present?
        p
      end

      def set_blank
        @blank = Blank.find(params[:id])

        # Add location prices if exist
        if @location.present?
            @blanks_location = BlanksLocationPrice.where(blanks_id: params[:id]).where(locations_id: @location[:id]).first
            if @blanks_location.present?
                @blank[:cost] = @blanks_location[:cost]
            end
        end
      end

      def update_blank_type(blank_type_id)
        @blank_type = BlankType.find_by_id(blank_type_id)
        @blank.update_attribute(:blank_type_id,  @blank_type.type_number)
      end

      def render_blanks_template(template_name: :index, status: :ok)
        render template: "api/v1/blanks/#{template_name.to_s}.json", status: status
      end

      def update_or_create_location_prices
        if @location.present?
            @blanks_location = BlanksLocationPrice.where(blanks_id: params[:id]).where(locations_id: @location[:id]).first
            if @blanks_location.present?
                @blanks_location.update(cost: params[:cost])
            else
                @blanks_location = BlanksLocationPrice.new(cost: params[:cost], locations_id: @location[:id], blanks_id: @blank[:id])
                @blanks_location.save
            end
            # Keep params that are not prices
            return params.require(:blank).permit(:id, :blank_number, :description, :blank_type_id)
        else
            return blank_params  # Keep all params if there are no location
        end
      end
    end
  end
end
