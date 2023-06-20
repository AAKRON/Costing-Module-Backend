FactoryBot.define do
  factory :blank_type do |f|
    sequence(:type_number)
    f.description { Faker::Lorem.sentence }
  end
end
