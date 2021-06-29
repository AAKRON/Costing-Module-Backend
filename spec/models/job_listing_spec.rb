require "rails_helper"

describe JobListing, type: :model do
  let(:job_listing) { build :job_listing}

  it "should belong to screen cost" do
    assc = described_class.reflect_on_association(:screen)
    expect(assc.macro).to eq :belongs_to
  end

  it "is valid with a description" do
    job_listing.description = "something"
    expect(job_listing).to be_valid
  end

  it "is invalid without a description" do
    job_listing.description = nil
    expect(job_listing).to_not be_valid
  end

  it {should validate_uniqueness_of(:job_number)}
end
