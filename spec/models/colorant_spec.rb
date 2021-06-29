require "rails_helper"

describe Colorant, type: :model do
  let(:colorant) { build :colorant }

  it "is valid with all attributes" do
    expect(colorant).to be_valid
  end

  it "should be invalid without a description" do
    colorant.description = nil
    expect(colorant).not_to be_valid
  end

  it "should be invalid without a cost" do
    colorant.cost = nil
    expect(colorant).not_to be_valid
  end
end
