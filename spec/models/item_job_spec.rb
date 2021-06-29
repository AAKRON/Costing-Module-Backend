require "rails_helper"

describe ItemJob, type: :model do
  let(:item_job) { build :item_job }

  it { should validate_uniqueness_of(:job_listing_id).scoped_to(:item_id).with_message("An item can only have one job type. Please select another job type.") }

  it "should belong to item" do
    assc = described_class.reflect_on_association :item
    expect(assc.macro).to eq :belongs_to
  end

  it "should belong to job listing" do
    assc = described_class.reflect_on_association :job_listing
    expect(assc.macro).to eq :belongs_to
  end

  it "is invalid without hours per pcs" do
    item_job.hour_per_piece = nil
    expect(item_job).to_not be_valid
  end
end
