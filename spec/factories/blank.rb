FactoryBot.define do
  factory :blank do |f|
    f.description { Faker::Shakespeare.hamlet[0] }
    f.number { Faker::Number.number 1 }
    f.type { 'manufactured' }
    cost {  Faker::Number.number 2 }
    item
  end
end
