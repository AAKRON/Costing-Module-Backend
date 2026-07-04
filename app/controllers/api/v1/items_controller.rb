# frozen_string_literal: true
module Api
  module V1
    class ItemsController < BaseController
      before_action :restrict_access
      before_action :set_user_access_level, only: [:destroy, :update]
      before_action :set_item, only: [:show, :update, :update_type]
      after_action(only: [:index]) { set_pagination_header(ItemCostView.count) }
      after_action(only: [:item_list_only]) { set_pagination_header(Item.count) }

      def index
        item_id = (params.fetch(:item_id, '') == 'null') ? '' : params.fetch(:item_id, '')
        ink_cost = (params.fetch(:ink_cost, '') == 'null') ? '' : params.fetch(:ink_cost, '')
        box_cost = (params.fetch(:box_cost, '') == 'null') ? '' : params.fetch(:box_cost, '')
        total_price_cost = (params.fetch(:total_price_cost, '') == 'null') ? '' : params.fetch(:total_price_cost, '')
        total_inventory_cost = (params.fetch(:total_inventory_cost, '') == 'null') ? '' : params.fetch(:total_inventory_cost, '')

        _start = params[:_start].to_i
        _end = params[:_end].to_i
        @items = ItemCostView.order("#{params[:_sort]} #{params[:_order]}").offset(_start).limit(_end - _start)
        @items = @items.search(item_id, :item_number) unless item_id.empty?
        @items = @items.search(params[:description], :description) unless params.fetch(:description, '').empty?
        @items = @items.search(params[:type_description], :type_description) unless params.fetch(:type_description, '').empty?
        @items = @items.where('lower(box_name) LIKE ?', "%#{params[:box_name]}%") unless params.fetch(:box_name, '').empty?
        @items = @items.where("number_of_pcs_per_box = #{params[:number_of_pcs_per_box]}") unless params.fetch(:number_of_pcs_per_box, '').empty?
        @items = @items.search(ink_cost, :ink_cost) unless ink_cost.empty?
        @items = @items.search(box_cost, :box_cost) unless box_cost.empty?
        @items = @items.search(total_price_cost, :total_price_cost) unless total_price_cost.empty?
        @items = @items.search(total_inventory_cost, :total_inventory_cost) unless total_inventory_cost.empty?

        render json: @items.map { |item|
          {
            id: item.id,
            item_number: item.item_number,
            description: item.description,
            type_description: item.type_description,
            item_type_id: item.item_type_id,
            number_of_pcs_per_box: item.number_of_pcs_per_box,
            box_name: item.box_name || 'none',
            ink_cost: item.ink_cost,
            box_cost: item.box_cost,
            total_price_cost: item.total_price_cost.round(5),
            total_inventory_cost: item.total_inventory_cost.round(5)
          }
        }, status: :ok
      end

      def show
        job_price_cost = 0.0
        job_inventory_cost = 0.0
        blank_price_cost = 0.0
        blank_inventory_cost = 0.0
        job_screen_cost = 0.0

        jobs_data = @item.item_jobs.map do |job|
          job = ItemJobDecorator.new(job)
          job_price_cost += job.total_pricing_cost.to_f
          job_inventory_cost += job.total_inventory_cost.to_f
          {
            job_number: job.job_number,
            description: job.description,
            wages_per_hour: job.wages_per_hour,
            hour_per_piece: job.hour_per_piece.round(5),
            direct_labor_cost: job.direct_labor_cost,
            overhead_inventory_cost: job.overhead_inventory_cost,
            overhead_pricing_cost: job.overhead_pricing_cost,
            total_inventory_cost: job.total_inventory_cost.round(5),
            total_pricing_cost: job.total_pricing_cost.round(5),
            job_listing_id: job.job_listing_id
          }
        end

        blanks_data = @item.blanks_listing_item_with_cost.map do |b|
          blank = BlankCostView.find_by_blank_number(b.blank_number)
          next if blank.nil?
          blank_cost_modifier = BlanksListingByItem.find_by_item_number_and_blank_number(@item.item_number, blank.blank_number)
          mult = blank_cost_modifier&.mult || 1
          div  = blank_cost_modifier&.div  || 1
          price_base     = blank.type_number == 1 ? blank.total_blank_cost_for_price.to_f     : blank.cost.round(5)
          inventory_base = blank.type_number == 1 ? blank.total_blank_cost_for_inventory.to_f : blank.cost.round(5)
          price_mod     = price_base     * mult / div
          inventory_mod = inventory_base * mult / div
          blank_price_cost     += price_mod
          blank_inventory_cost += inventory_mod
          row = {
            blank_number: blank.blank_number,
            description: blank.description,
            blank_type: blank.blank_type,
            type_number: blank.type_number,
            cost: blank.cost,
            total_blank_cost_for_price: (blank.type_number == 1 ? blank.total_blank_cost_for_price : blank.cost),
            total_blank_cost_for_inventory: (blank.type_number == 1 ? blank.total_blank_cost_for_inventory : blank.cost),
            total_blank_cost_for_price_modify: price_mod,
            total_blank_cost_for_inventory_modify: inventory_mod
          }
          unless blank_cost_modifier.nil?
            row[:multiplication] = mult
            row[:division] = div
          end
          row
        end.compact

        screen_data = @item.item_jobs.map do |job|
          job = ItemJobDecorator.new(job)
          job_listing = JobListing.find_by_id(job.job_listing_id)
          next if job_listing.nil? || job_listing.screen.nil?
          job_screen_cost += job_listing.screen.cost.to_f
          {
            job_listing_id: job.job_listing_id,
            job_number: job.job_number,
            description: job.description,
            screen_name: job_listing.screen.screen_size,
            screen_cost: job_listing.screen.cost.round(5)
          }
        end.compact

        result = {
          id: @item.id,
          item_number: @item.item_number,
          description: @item.description,
          number_of_pcs_per_box: @item.number_of_pcs_per_box,
          ink_cost: @item.ink_cost.round(5),
          box_cost: @item.box_cost,
          box_id: @item.box_id,
          item_type_id: @item.item_type_id,
          type_number: @item.item_type.type_number,
          jobs: jobs_data,
          blanks: blanks_data,
          screen: screen_data,
          job_price_cost: job_price_cost.round(5),
          job_inventory_cost: job_inventory_cost.round(5),
          job_screen_cost: job_screen_cost.round(5),
          item_box_cost: @item.box_cost.round(5),
          blank_price_cost: blank_price_cost.round(5),
          blank_inventory_cost: blank_inventory_cost.round(5),
          total_price_cost: (blank_price_cost.round(5) + job_price_cost.round(5) + job_screen_cost.round(5) + @item.box_cost.round(5) + @item.ink_cost.to_f.round(5)).round(5),
          total_inventory_cost: (blank_inventory_cost.round(5) + job_inventory_cost.round(5) + job_screen_cost.round(5) + @item.box_cost.round(5) + @item.ink_cost.to_f.round(5)).round(5)
        }
        unless @item.box.nil?
          result[:box_name] = @item.box.name
          result[:box_cost] = @item.box.cost_per_box.to_f.round(5)
        end
        render json: result, status: :ok
      end

      def create
        @item = Item.new(item_params)

        if @item.save
          render json: @item, status: 201
        else
          render json: @item.errors, status: 400
        end
      end

      def update
        if @item.update(item_params)
          render json: @item, status: :ok
        else
          render json: @item.errors.messages, status: :bad_request
        end
      end

      def destroy
        Item.find(params[:id]).destroy
      end

      def item_list_only
        @items = Item.all
        render json: @items, status: :ok
      end

      def update_type
        if params[:apikey] != ENV['ITEM_TYPE_UPDATE_APIKEY']
          render json: { message: 'Not Authorized' }, status: 401
        else
          if @item.present?
            @item_type = ItemType.where('description = ?', "#{params[:item_type]}").first
            if @item_type.present?
              @item.update(item_type_id: @item_type.type_number)
              render json: { item: @item, item_type: @item_type }, status: :ok
            else
              render json: { message: 'ItemType not found', status: :bad_request }
            end
          else
            render json: { message: 'item not found', status: :bad_request }
          end
        end
      end

      private

      def item_params
        params.require(:item).permit(:item_number, :description, :box_id, :item_type_id, :number_of_pcs_per_box, :ink_cost)
      end

      def set_item
        @item = Item.find(params[:id])
      end
    end
  end
end
