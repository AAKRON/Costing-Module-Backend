require "rails_helper"

describe BlankRawMaterial, type: :model do
  let(:blank_raw_material) { build :blank_raw_material }

  it "should belong to blank" do
    assc = described_class.reflect_on_association :blank
    expect(assc.macro).to eq :belongs_to
  end

  it "should belong to raw_material" do
    assc = described_class.reflect_on_association :raw_material
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with all attributes" do
    expect(blank_raw_material).to be_valid
  end

  it "is invalid without the hour_per_unit_of_measure" do
    blank_raw_material.piece_per_unit_of_measure = nil
    expect(blank_raw_material).not_to be_valid
  end
end
