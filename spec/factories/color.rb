FactoryBot.define do
  factory :color do |f|
    sequence(:code)
    f.name { Faker::Lorem.sentence }
  end
end
