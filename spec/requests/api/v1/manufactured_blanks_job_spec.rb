require "rails_helper"

describe "API::V1::ManufacturedBlanksJob" do
  describe "GET /manufactured_blanks_job" do
    before do
      create(:app_constant, :inventory_overhead_percentage)
      create(:app_constant, :price_overhead_percentage)

      5.times do
        manufactured_blank = create(:manufactured_blank)
        job_listing = create(:job_listing, wages_per_hour: 10.50)
        create(:manufactured_blank_job, hour_per_piece: 0.0025, 
               manufactured_blank: manufactured_blank, job_listing: job_listing)
      end
    end

    it "returns a collection of manufactured blanks and their required keys" do
      required_keys = [:id, :blank_number, :description, :number_of_jobs, :jobs]

      get_with_token api_v1_manufactured_blank_jobs_path

      expect(json.length).to eq 5
      expect(json[0].keys.map(&:to_sym)).to match_array(required_keys)
    end
  end
end
