require 'rails_helper'

describe 'Api::V1::Color' do
  describe 'GET /colors' do
    before do
      5.times { create(:color) }
    end

    it 'returns all colors from the database for a user with token' do
      required_keys = %w(id code name created_at updated_at)

      get_with_token api_v1_colors_path

      expect(response.status).to eq 200
      expect(json.length).to eq 5
      expect(json[0].keys).to match_array(required_keys.map(&:to_sym))
    end
  end

  describe 'POST /create' do
    before do
      @color_params = attributes_for(:color)
    end

    it "allows user with token to create a new color" do
      expect {
        post_with_token api_v1_colors_path, {color: @color_params}
      }.to change{Color.count}.by(1)

      expect(response.status).to eq 201
    end
  end
end