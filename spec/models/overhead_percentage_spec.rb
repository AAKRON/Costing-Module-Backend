require "rails_helper"

describe OverheadPercentage, type: :model do
  let(:overhead_percentage) { create(:overhead_percentage)}
  it "is valid with valid attributes" do
    expect(overhead_percentage.valid?).to be true
  end

  it "is composed of types inventory and pricing" do
    expect(overhead_percentage.type).to eq 'inventory'
  end
end
