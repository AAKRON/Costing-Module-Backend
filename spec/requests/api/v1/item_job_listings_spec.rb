require "rails_helper"

#describe "ItemJobListing API" do
#  before do
#    create(:app_constant, :inventory_overhead_percentage)
#    create(:app_constant, :price_overhead_percentage)
#  end
#
#  describe "GET /item_job_listing" do
#    before do
#      @item = create(:item)
#      @job_listing = create(:job_listing, wages_per_hour: 10.50)
#      create(:item_job, hour_per_piece: 0.0025, item: @item, job_listing: @job_listing)
#    end
#
#    it "returns the expected result" do
#      expected_dir_labor_cost = "0.026"
#      expected_overhead_inventory = "0.025"
#      expected_overhead_pricing = "0.104"
#
#      get_with_token api_v1_item_job_listing_path @item.id
#      result = json[:item_job_listings]
#
#      expect(result[:jobs][0][:direct_labor_cost]).to eq expected_dir_labor_cost
#      expect(result[:jobs][0][:overhead_inventory_cost]).to eq expected_overhead_inventory
#      expect(result[:jobs][0][:overhead_pricing_cost]).to eq expected_overhead_pricing
#    end
#
#
#      it "returns the required keys and the overhead percentage for inventory" do
#        item_keys = %w(id item_number description jobs)
#        job_keys = %w(job_number wages_per_hour  hour_per_piece direct_labor_cost overhead_inventory_cost overhead_pricing_cost )
#
#        get_with_token api_v1_item_job_listing_path(@item.id), overhead_percentage: 'inventory'
#
#        result = json[:item_job_listings]
#        job = result[:jobs][0]
#
#        expect(result.keys).to match_array(item_keys.map(&:to_sym))
#        expect(job.keys).to match_array(job_keys.map(&:to_sym))
#      end
#  end
#
#  describe "GET /item_job_listings" do
#    context 'with valid parameters' do
#      before do
#        5.times do
#          item = create(:item)
#          job_listing = create(:job_listing, wages_per_hour: 10.50)
#          create(:item_job, hour_per_piece: 0.0025, item: item, job_listing: job_listing)
#        end
#      end
#
#      it "returns a collection of item, their jobs and the calculated result" do
#        get_with_token api_v1_item_job_listings_path
#
#        expect(json.length).to eq 5
#      end
#    end
#  end
#end
