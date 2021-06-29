FactoryGirl.define do
  factory :raw_material do |f|
    name  Faker::Lorem.word
    cost_per_unit Faker::Number.number 1
    unit_of_measure Faker::Lorem.characters 2
  end
end
