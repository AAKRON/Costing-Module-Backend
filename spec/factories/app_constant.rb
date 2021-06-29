FactoryGirl.define do
  factory :app_constant do
    name 'aakron constant for pricing'.freeze
    value 100

    trait :inventory_overhead_percentage do
      name 'inventory_overhead_percentage'
      value 0.9569
    end

    trait :price_overhead_percentage do
      name 'price_overhead_percentage'
      value 4
    end
  end
end
