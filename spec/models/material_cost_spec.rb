require "rails_helper"

describe MaterialCost, type: :model do
  let(:material_cost) { build :material_cost }

  it "should belong to item_listing" do
    assc = described_class.reflect_on_association :item
    expect(assc.macro).to eq :belongs_to
  end
end
