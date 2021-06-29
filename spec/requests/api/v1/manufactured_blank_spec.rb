require "rails_helper"

describe "ManufacturedBlank Listing API" do
  describe "GET /manufactured-blanks" do
    before do
      5.times { create(:manufactured_blank) }
    end

    it "returns all manufactured blanks for a valid user with token" do
      required_keys = %w(id blank_number description)

      get_with_token api_v1_manufactured_blanks_path

      expect(response.status).to eq 200
      expect(json.length).to eq 5
      expect(json[0].keys).to match_array(required_keys.map(&:to_sym))
    end
  end

  describe "POST /manufactured-blanks" do
    before do
      @manufactured_blanks_params = attributes_for(:manufactured_blank)
    end

    it "allows user with token to create a new manufactured blank" do
     expect {
        post_with_token api_v1_manufactured_blanks_path, {manufactured_blank: @manufactured_blanks_params}
     }.to change{ManufacturedBlank.count}.by(1)

      expect(response.status).to eq 201
    end
  end

  describe "PUT /manufactured_blank/id" do
    let(:manufactured_blank) { create :manufactured_blank }

    it 'updates an existing item' do
      put_with_token(api_v1_manufactured_blank_path(manufactured_blank.id), {manufactured_blank: {blank_number: 344, description:  "awesome blank aakron"}})

      expect(json[:blank_number]).to eq 344
      expect(json[:description]).to eq "awesome blank aakron"
    end
  end

  describe "DELETE /manufactured_blank/id" do
    it 'removes the manufactured blank from the database' do
      @manufactured_blank  = create :manufactured_blank
      mb_count = ManufacturedBlank.count

      delete_with_token api_v1_manufactured_blank_path(@manufactured_blank.id)

      expect(ManufacturedBlank.count).not_to eq mb_count
    end
  end
end
