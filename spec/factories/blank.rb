FactoryBot.define do
  factory :blank do |f|
    sequence(:blank_number)
    f.description { Faker::Lorem.sentence }
    cost {  Faker::Number.number(digits: 2) }
    blank_type
  end
end
