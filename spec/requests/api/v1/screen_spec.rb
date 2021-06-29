require "rails_helper"

describe "Screen API" do

  describe "GET /screens" do
    before do
      screen_sizes = [:small, :medium, :large]
      screen_sizes.each{ |size| create(:screen, screen_size: size) }
    end

    it "returns all screen sizes for user with valid token" do
      required_keys = %w(id cost screen_size)

      get_with_token api_v1_screens_path

      expect(json[0].keys).to match_array(required_keys.map(&:to_sym))
      expect(response.status).to eq 200
      expect(json.length).to eq 3
    end
  end

  describe "POST /screen" do
    before do
      @screen_params = attributes_for(:screen)
    end

    it "allows user with a token to create a screen" do
     expect {
        post_with_token api_v1_screens_path, {screen: @screen_params}
     }.to change{Screen.count}.by(1)

      expect(response.status).to eq 201
    end

    it "disallows user without a token to create a screen" do
      expect {
        post api_v1_screens_path, params: {screen: @screen_params}
      }.to_not change{Screen.count}

      expect(response.status).to eq 401
    end

    it "returns a screen with the required json keys" do
      required_keys = %w(id cost screen_size)

      post_with_token api_v1_screens_path, {screen: @screen_params}

      expect(response.status).to eq 201
      expect(json[:screens].keys).to match_array(required_keys.map(&:to_sym))
    end
  end
end
