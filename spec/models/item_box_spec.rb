require "rails_helper"

describe ItemBox, type: :model do
  let(:item_box) { build :item_box }

  it "should belong to item" do
    assc = described_class.reflect_on_association :item
    expect(assc.macro).to eq :belongs_to
  end

  it "should belong to box" do
    assc = described_class.reflect_on_association :box
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with pieces_per_box" do
    expect(item_box).to be_valid
  end

  it "is invalid without pieces_per_box" do
    item_box.pieces_per_box = nil
    expect(item_box).not_to be_valid
  end
end
