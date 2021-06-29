require "rails_helper"

describe OverheadCost, type: :model do
  let(:overhead_cost) { build(:overhead_cost)}

  it "has one overhead percentage" do
    assc = described_class.reflect_on_association(:overhead_percentage)
    expect(assc.macro).to eq :belongs_to
  end

  it "belongs to job_listing" do
    assc = described_class.reflect_on_association(:job_listing)
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with overhead_percentage_id and job_listing_id" do
    expect(overhead_cost).to be_valid
  end

  it "is invalid without an overhead percentage id" do
    overhead_cost.overhead_percentage_id = nil
    expect(overhead_cost).to_not be_valid
  end

  it "is invalid without a job listing id" do
    overhead_cost.job_listing_id = nil
    expect(overhead_cost).to_not be_valid
  end
end
