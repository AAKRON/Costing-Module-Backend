require "rails_helper"

describe "Item Listing API" do
  describe "POST /items" do
    before do
      @item_params = attributes_for(:item)
    end

    it "allows user with token to create a new item" do
     expect {
        post_with_token api_v1_items_path, {item: @item_params}
     }.to change{Item.count}.by(1)

      expect(response.status).to eq 201
    end

    it "disallows user without a token from creating a new item" do

      expect {
        post api_v1_items_path, params: {item: @item_params}
      }.to_not change{Item.count}

      expect(response.status).to eq 401
    end

    it "returns an error message when the required item_no is not a number" do
     expect {
        post_with_token api_v1_items_path, {item: {item_no: nil}}
     }.to_not change{Item.count}
    end
  end

  describe "PUT /items/id" do
    let(:item) { create :item }

    it 'updates an existing item' do
      put_with_token(api_v1_item_path(item.id), {item: {item_number: 344, description:  "awesome aakron"}})

      expect(json[:item_number]).to eq 344
      expect(json[:description]).to eq "awesome aakron"
    end
  end

  describe "GET /items" do
    before do
      5.times { create(:item) }
    end

    it "returns all items for a valid user with token" do
      required_keys = %w(id item_number description)

      get_with_token api_v1_items_path

      expect(response.status).to eq 200
      expect(json.length).to eq 5
      expect(json[0].keys).to match_array(required_keys.map(&:to_sym))
    end
  end

  describe "DELETE /items/id" do
    it 'removes the item from the database'do
      @item = create(:item)
      item_count = Item.count

      delete_with_token api_v1_item_path(@item.id)

      expect(Item.count).not_to eq item_count
    end
  end
end
