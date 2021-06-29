require "rails_helper"

describe Box, type: :model do
  let(:box) { build :box }

  it "is valid with all attributes" do
    expect(box).to be_valid
  end

  it "is invalid without a name" do
    box.name = nil
    expect(box).not_to be_valid
  end

  it "is invalid without a cost per unit" do
    box.cost_per_unit = nil
    expect(box).not_to be_valid
  end
end
