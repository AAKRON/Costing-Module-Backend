require 'rails_helper'

describe StringSanitizer do
  it {expect(StringSanitizer.new("foo")).to respond_to(:snakify)}
  it "raise an exception" do
    allow(described_class).to receive(:new).with(nil).and_raise(StringSanitizer::NoValueError)
  end

  describe "#snakify" do
    it "transform a string to snake case" do
      expect(described_class.new("I am the boss").snakify).to eq "i_am_the_boss"
    end
  end
end
