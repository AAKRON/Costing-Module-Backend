require "rails_helper"

describe "JobListing API" do

  describe "POST /job_listings" do
    before do
      @job_listing_params = build(:job_listing).attributes.symbolize_keys
    end

    it "allows user with a token to create a job" do
     expect {
        post_with_token api_v1_job_listings_path, {job_listing: @job_listing_params}
     }.to change{JobListing.count}.by(1)

      expect(response.status).to eq 201
    end

    it "returns an error message when all required params is not provided" do
        post_with_token api_v1_job_listings_path, {job_listing: {wages_per_hour: nil}}

        expect(response.status).to eq 400
        expect(json[:description]).to eq ["can't be blank"]
    end

   it "disallows user without a token to create a job" do
      expect {
        post api_v1_job_listings_path, params: {job_listing: @job_listing_params}
      }.to_not change{JobListing.count}

      expect(response.status).to eq 401
    end

    it "returns a screen with the required json keys" do
      required_keys = %w(id description wages_per_hour screen_size job_number)

      post_with_token api_v1_job_listings_path, {job_listing: @job_listing_params}

      expect(response.status).to eq 201
      expect(json[:job_listing].keys).to eq required_keys.map(&:to_sym)
    end
  end

  describe "PUT /job_listings" do
    context 'with valid parameters' do
      let(:job) { create(:job_listing, job_number: 2345) }

      it 'updates an existing items' do
        put_with_token(api_v1_job_listing_path(job.id), {job_listing: {description:  "aakron job", job_number: job.job_number}})

        expect(json[:description]).to eq "aakron job"
        expect(response.status).to eq 200
      end
    end

    context 'with invalid parameters' do
      let(:job) { create(:job_listing, job_number: 2345) }

      it 'does not update the items' do
        put_with_token(api_v1_job_listing_path(job.id), {job_listing: {description: nil}})

        expect(json[:description]).to eq ["can't be blank"]
      end
    end
  end

  describe "GET /job_listings" do
    it "returns all job listings for user with token" do
      5.times { |i| create(:job_listing, job_number: i) }
      required_keys = %w(id description wages_per_hour screen_size job_number)

      get_with_token api_v1_job_listings_path

      expect(response.status).to eq 200
      expect(json.length).to eq 5
      expect(json.last.keys).to match_array(required_keys.map(&:to_sym))
    end

    it "returns a message for empty job listing" do
      get_with_token api_v1_job_listings_path

      expect(response.status).to eq 200
      expect(json).to be_empty
    end
  end
end
