FactoryBot.define do
  factory :item do |f|
    sequence(:item_number)
    f.description { Faker::Lorem.sentence }
  end
end
