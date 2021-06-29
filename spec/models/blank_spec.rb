require "rails_helper"

describe Blank, type: :model do
  let(:blank) { build :blank }

  it "should belong to blank" do
    assc = described_class.reflect_on_association :item
    expect(assc.macro).to eq :belongs_to
  end

  it "should be valid with all attributes" do
    expect(blank).to be_valid
  end

  it "validates number to be present" do
    blank.number = nil
    expect(blank).to_not be_valid
  end

end
