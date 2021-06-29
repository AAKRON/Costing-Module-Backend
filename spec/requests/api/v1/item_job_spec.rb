require "rails_helper"

describe "API:V1::ItemJob" do
  before do
    create(:app_constant, :inventory_overhead_percentage)
    create(:app_constant, :price_overhead_percentage)
  end

  describe "POST /items" do
    before do
      @item = create(:item)
      @job_listing = create(:job_listing)
    end

    context "user with token" do
      it "raises an error when the item is not found" do
        expect {
          post_with_token api_v1_item_jobs_path, {item_job: {item_id: nil}}
        }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Item")
      end

      it "creates the itemjob if the job_listing and the item exist" do
        required_keys = [:hour_per_piece, :direct_labor_cost, :job_number, :overhead_inventory_cost, :overhead_pricing_cost, :wages_per_hour, :job_listing_id, :description]

        expect {
          post_with_token api_v1_item_jobs_path, {item_number: @item.id, item_jobs: [{job_listing_id: @job_listing.id, hour_per_piece: 20}] }
        }.to change{ItemJob.count}.by(1)

        item_job = json[:item_job_listings][:jobs].first

        expect(item_job.keys.map(&:to_sym)).to match_array(required_keys)
      end
    end

    describe "GET /item_jobs" do
      before do
        @item = create(:item)
        @job_listing = create(:job_listing, wages_per_hour: 10.50)
        create(:item_job, hour_per_piece: 0.0025, item: @item, job_listing: @job_listing)
      end

      it "returns the expected result" do
        expected_dir_labor_cost = "0.0262"
        expected_overhead_inventory = "0.0251"
        expected_overhead_pricing = "0.1048"

        get_with_token api_v1_item_job_path @item.id
        item_jobs = json[:item_job_listings][:jobs].first

        expect(item_jobs[:direct_labor_cost]).to eq expected_dir_labor_cost
        expect(item_jobs[:overhead_inventory_cost]).to eq expected_overhead_inventory
        expect(item_jobs[:overhead_pricing_cost]).to eq expected_overhead_pricing
      end


      it "returns the required keys and the overhead percentage for inventory" do
        item_keys = %w(id item_number description jobs number_of_jobs).freeze
        job_keys = %w(job_number wages_per_hour  hour_per_piece direct_labor_cost overhead_inventory_cost overhead_pricing_cost job_listing_id description).freeze

        get_with_token api_v1_item_job_path(@item.id), overhead_percentage: 'inventory'

        item = json[:item_job_listings]
        item_job = item[:jobs].first

        expect(item.keys).to match_array(item_keys.map(&:to_sym))
        expect(item_job.keys).to match_array(job_keys.map(&:to_sym))
      end
    end

    describe "GET /item_job_listings" do
      context 'with valid parameters' do
        before do
        Item.destroy_all
          5.times do
            item = create(:item)
            job_listing = create(:job_listing, wages_per_hour: 10.50)
            create(:item_job, hour_per_piece: 0.0025, item: item, job_listing: job_listing)
          end
        end

        it "returns a collection of item, their jobs and the calculated result" do
          get_with_token api_v1_item_jobs_path

          expect(json.length).to eq 5
        end
      end
    end
  end
end
