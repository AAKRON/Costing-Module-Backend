require 'rails_helper'

RSpec.describe Api::V1::ItemsController, type: :controller do
  render_views

  describe "GET index" do
    before(:each) do
      4.times { create(:item_job) }
      @items = Item.all
      @user = create(:user)
    end

    it "returns a status code of 200 for a request with a valid token" do
      get :index, user_token: @user.token

      expect(response.status).to eq 200
    end

    it "returns a status code of 401 for a request without a valid user token" do
      get :index

      expect(response.status).to eq 401
    end

    it "returns an array of 4 items" do
      get :index, user_token: @user.token

      body = JSON.parse(response.body)["items"]

      expect(body.count).to eq 4
    end

    it "returns an error for a request without token" do
      get :index

      body = JSON.parse(response.body)

      expect(body["message"]).to eq "Not Authorized"
    end

    it "returns items having the required keys" do
      required_keys = [:id, :item_no, :labor_cost,
        :overhead_cost, :material_cost, :pricing, :inventory]

        get :index, user_token: @user.token
        binding.pry
        body = JSON.parse(response.body)["items"][0]
        expect(body.keys).to match required_keys.map(&:to_s)
    end
  end
end
