require 'rails_helper'

RSpec.describe AppConstant, type: :model do
  it {should have_db_column(:value) }
  it {should have_db_column(:value) }
  it {should have_db_column(:name) }
  it {should validate_presence_of(:name)}
  it {should validate_presence_of(:value)}

  it "creates a constant called 'inventory_overhead_percentage'" do
    new_constant = build(:app_constant, name: "inventory overhead percentage")

    new_constant.save

    expect(new_constant.name).to eq 'inventory_overhead_percentage'
  end

  it 'validates uniquness of name' do
    create(:app_constant)

    expect { create(:app_constant) }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Name has already been taken')
  end

  it "creates a constant that can be easily accessible" do
    create(:app_constant, value: 200, name: 'pricing_overhead_percentage')

    expect(AppConstant.find_by_name(:pricing_overhead_percentage).to_i).to eq 200
  end

end
