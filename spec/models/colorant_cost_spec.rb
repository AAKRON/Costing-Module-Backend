require "rails_helper"

describe ColorantCost, type: :model do
  let(:colorant) { build :colorant_cost }

  it "should belong to blank" do
    assc = described_class.reflect_on_association :blank
    expect(assc.macro).to eq :belongs_to
  end

  it "should belong to colorant" do
    assc = described_class.reflect_on_association :colorant
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with all attributes" do
    expect(colorant).to be_valid
  end

  it "is invalid without a colorant percentage" do
    colorant.colorant_percentage = nil
    expect(colorant).not_to be_valid
  end
end
