require "rails_helper"

describe ItemBlankJobPiece, type: :model do
  let(:item_blank_job_piece) { build :item_blank_job_piece }

  it "should belong to item_job" do
    assc = described_class.reflect_on_association :item_job
    expect(assc.macro).to eq :belongs_to
  end

  it "should belong to blank" do
    assc = described_class.reflect_on_association :blank
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with all attributes" do
    expect(item_blank_job_piece).to be_valid
  end

  it "is invalid without hour_per_piece" do
    item_blank_job_piece.hour_per_piece = nil
    expect(item_blank_job_piece).to_not be_valid
  end
end
