FactoryGirl.define do
  factory :blank_raw_material do |f|
    piece_per_unit_of_measure Faker::Number.number 2
    cost  Faker::Number.number 1
    blank
    raw_material
  end
end
